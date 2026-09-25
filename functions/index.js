const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const apn = require('@parse/node-apn'); // 📞 VoIP için APNs modülü

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

// ⚠️ BURAYI KENDİ BİLGİLERİNİZLE DOLDURUN VE .p8 DOSYASINI BU KLASÖRE KOYUN ⚠️
const apnOptions = {
    token: {
        key: __dirname + "/AuthKey_7BGV4PGN3M.p8", // İndirdiğiniz .p8 dosyasının İSMİ
        keyId: "7BGV4PGN3M",                // Apple Developer'daki 10 haneli Key ID
        teamId: "32QGKVDU76"               // Apple Developer'daki 10 haneli Team ID
    },
    production: false // TestFlight / Geliştirme için false. App Store için true.
};
let apnProvider = new apn.Provider(apnOptions);

/**
 * Arama oluşturulduğunda tetiklenen v2 fonksiyonu
 * VoIP ve Standart Push bildirimlerini yönetir.
 */
exports.oncallcreated = onDocumentCreated("Calls/{callId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return null;

    const data = snapshot.data();
    const receiverId = data.receiverId;
    const callerId = data.callerId;
    const isVideo = data.type === "video";

    console.log(`🚀 Yeni arama (v2): ${callerId} -> ${receiverId}`);

    try {
        // --- 1. Alıcının Bilgilerini ve Token'larını Bul ---
        let receiverData = null;

        // Önce yayıncılarda (PublisherProfile) ara
        let receiverDoc = await admin.firestore().collection("PublisherProfile").doc(receiverId).get();
        if (receiverDoc.exists) {
            receiverData = receiverDoc.data();
        } else {
            // Yayıncılarda yoksa normal kullanıcılarda (UserWatcher) ara
            receiverDoc = await admin.firestore().collection("UserWatcher").doc(receiverId).get();
            if (receiverDoc.exists) {
                receiverData = receiverDoc.data();
            }
        }

        if (!receiverData) {
            console.log(`⚠️ Alıcı (${receiverId}) bulunamadı!`);
            return null;
        }

        const msgToken = receiverData.msgToken;
        const voipToken = receiverData.voipToken;
        const receiverName = receiverData.name || "Alıcı";

        // --- 2. Arayanın Adını Bul ---
        let callerName = "Bir kullanıcı";
        let callerDoc = await admin.firestore().collection("UserWatcher").doc(callerId).get();
        if (!callerDoc.exists) {
            callerDoc = await admin.firestore().collection("PublisherProfile").doc(callerId).get();
        }

        if (callerDoc.exists) {
            callerName = callerDoc.data().name || callerName;
        }

        // --- 3. VoIP Bildirimi Gönder (Uygulama kapalıyken çaldırmak için) ---
        if (voipToken) {
            let note = new apn.Notification();
            note.pushType = "voip";
            note.topic = "com.boraates.MorChatApp.voip"; // Uygulamanızın Bundle ID'si + .voip
            note.payload = {
                callId: event.params.callId,
                callerId: callerId,
                video: isVideo ? "true" : "false",
                callerName: callerName
            };

            try {
                const result = await apnProvider.send(note, voipToken);
                console.log(`✅ VoIP Push Sonucu (${receiverName}):`, JSON.stringify(result));
            } catch (err) {
                console.error("❌ VoIP Push hatası:", err);
            }
        }

        // --- 4. Standart Bildirimi Gönder (Banner olarak görünmesi için) ---
        if (msgToken) {
            const alertTitle = isVideo ? "Goruntulu Arama" : "Sesli Arama";
            const alertBody = `${callerName} seni ariyor...`;
            const standardMessage = {
                notification: {
                    title: alertTitle,
                    body: alertBody,
                },
                data: {
                    callId: event.params.callId,
                    callerId: callerId,
                    callerName: callerName,
                    isVideo: isVideo ? "true" : "false",
                    click_action: "CALL_ACTION"
                },
                token: msgToken,
                apns: {
                    headers: {
                        "apns-priority": "10",
                        "apns-push-type": "alert",
                    },
                    payload: {
                        aps: {
                            alert: {
                                title: alertTitle,
                                body: alertBody,
                            },
                            sound: "default",
                            badge: 1,
                        }
                    }
                }
            };
            await admin.messaging().send(standardMessage);
            console.log(`✅ Standart Push gönderildi: ${receiverName}`);
        }

    } catch (error) {
        console.error("❌ Genel Bildirim hatası:", error);
    }
    return null;
});
