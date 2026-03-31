const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

/**
 * Arama oluşturulduğunda tetiklenen v2 fonksiyonu
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
        // --- 1. Alıcının msgToken'ını Bul ---
        let token = null;
        let receiverName = "Alıcı";

        // Önce yayıncılarda (PublisherProfile) ara
        let receiverDoc = await admin.firestore().collection("PublisherProfile").doc(receiverId).get();
        if (receiverDoc.exists) {
            token = receiverDoc.data().msgToken;
            receiverName = receiverDoc.data().name || receiverName;
        } else {
            // Yayıncılarda yoksa normal kullanıcılarda (UserWatcher) ara
            receiverDoc = await admin.firestore().collection("UserWatcher").doc(receiverId).get();
            if (receiverDoc.exists) {
                token = receiverDoc.data().msgToken;
                receiverName = receiverDoc.data().name || receiverName;
            }
        }

        if (!token) {
            console.log(`⚠️ Alıcı (${receiverId}) bulunamadı veya msgToken'ı yok!`);
            return null;
        }

        // --- 2. Arayanın Adını Bul (Bildirim Başlığı İçin) ---
        let callerName = "Bir kullanıcı";
        // Arayan hem yayıncı hem normal kullanıcı olabilir
        let callerDoc = await admin.firestore().collection("UserWatcher").doc(callerId).get();
        if (callerDoc.exists) {
            callerName = callerDoc.data().name || callerName;
        } else {
            callerDoc = await admin.firestore().collection("PublisherProfile").doc(callerId).get();
            if (callerDoc.exists) {
                callerName = callerDoc.data().name || callerName;
            }
        }

        // --- 3. Bildirimi Fırlat ---
        const message = {
            notification: {
                title: isVideo ? "Görüntülü Arama" : "Sesli Arama",
                body: `${callerName} seni arıyor...`,
            },
            data: {
                callId: event.params.callId,
                isVideo: isVideo ? "true" : "false",
                click_action: "CALL_ACTION"
            },
            token: token,
            // iOS için kritik ayarlar:
            apns: {
                headers: {
                    "apns-priority": "10",      // Yüksek öncelik (Kilitli ekranı uyandırır)
                    "apns-push-type": "alert"   // Bildirim tipi
                },
                payload: {
                    aps: {
                        sound: "default",
                        badge: 1,
                        "content-available": 1,   // Arka planda uyandırmayı tetikler
                        "mutable-content": 1      // Gerekirse zengin içerik modu
                    }
                }
            },
            // Android için kritik ayarlar:
            android: {
                priority: "high",
                notification: {
                    sound: "default",
                    priority: "high"
                }
            }
        };

        await admin.messaging().send(message);
        console.log(`✅ Bildirim gönderildi: ${callerName} -> ${receiverName}`);
    } catch (error) {
        console.error("❌ Bildirim hatası:", error);
    }
    return null;
});
