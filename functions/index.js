const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

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
            const voipPayload = {
                token: voipToken,
                data: {
                    callId: event.params.callId,
                    callerId: callerId,
                    video: isVideo ? "true" : "false"
                },
                apns: {
                    headers: {
                        "apns-priority": "10",
                        "apns-push-type": "voip"
                    },
                    payload: {
                        aps: {
                            "content-available": 1
                        }
                    }
                }
            };

            try {
                await admin.messaging().send(voipPayload);
                console.log(`✅ VoIP Push gönderildi: ${receiverName}`);
            } catch (err) {
                console.error("❌ VoIP Push hatası:", err);
            }
        }

        // --- 4. Standart Bildirimi Gönder (Banner olarak görünmesi için) ---
        if (msgToken) {
            const standardMessage = {
                notification: {
                    title: isVideo ? "Görüntülü Arama" : "Sesli Arama",
                    body: `${callerName} seni arıyor...`,
                },
                data: {
                    callId: event.params.callId,
                    isVideo: isVideo ? "true" : "false",
                    click_action: "CALL_ACTION"
                },
                token: msgToken,
                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                            badge: 1
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
