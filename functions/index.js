const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();

// Global ayarlar (Bölge vb. gerekirse buraya eklenir)
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
        // 1. Alıcının msgToken'ını bul (UserWatcher üzerinden)
        const receiverDoc = await admin.firestore().collection("UserWatcher").doc(receiverId).get();
        if (!receiverDoc.exists) {
            console.log("⚠️ Alıcı dökümanı bulunamadı!");
            return null;
        }
        
        const token = receiverDoc.data().msgToken;
        if (!token) {
            console.log("⚠️ Alıcının FCM Jetonu (msgToken) yok!");
            return null;
        }

        // 2. Arayan kişinin adını bul (UserWatcher üzerinden)
        const callerDoc = await admin.firestore().collection("UserWatcher").doc(callerId).get();
        const callerName = callerDoc.exists ? (callerDoc.data().name || "Bir kullanıcı") : "Bir kullanıcı";

        // 3. Mesajı gönder
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
            apns: {
                payload: {
                    aps: {
                        sound: "default",
                        badge: 1
                    }
                }
            }
        };

        await admin.messaging().send(message);
        console.log("✅ Bildirim gönderildi");
    } catch (error) {
        console.error("❌ Hata:", error);
    }
    return null;
});

/**
 * Genel bildirimler için v2 tetikleyici
 */
exports.onwatchernotification = onDocumentCreated("NotificationListWatcher/{notifId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return null;
    
    const data = snapshot.data();
    const receiverToken = data.receiverToken;

    if (!receiverToken) return null;

    const message = {
        notification: {
            title: data.title || "Yeni Bildirim",
            body: data.message || "Bir güncellemeniz var.",
        },
        token: receiverToken,
    };

    try {
        await admin.messaging().send(message);
        console.log("✅ Genel bildirim gönderildi");
    } catch (error) {
        console.log("❌ Hata:", error);
    }
    return null;
});
