import Foundation

final class NotificationSender {
    
    static let shared = NotificationSender()
    
    // 🔥 ÖNEMLİ: Firebase Console > Proje Ayarları > Cloud Messaging kısmından 
    // "Legacy Server Key" (Eski Sunucu Anahtarı) veya "FCM Server Key" almanız gerekir.
    // Eğer Legacy olan aktif değilse, yanındaki üç noktadan yönetip aktif edebilirsiniz.
    private let serverKey = "YOUR_FIREBASE_SERVER_KEY_HERE"
    
    func sendCallNotification(to token: String, callerName: String, isVideo: Bool, callId: String) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Bildirim İçeriği
        let title = isVideo ? "notif_video_call".localized : "notif_voice_call".localized
        let body = String(format: "notif_calling_body".localized, callerName)
        
        let payload: [String: Any] = [
            "to": token,
            "notification": [
                "title": title,
                "body": body,
                "sound": "default",
                "badge": 1
            ],
            "data": [
                "callId": callId,
                "callerName": callerName,
                "isVideo": isVideo ? "true" : "false",
                "click_action": "CALL_ACTION"
            ],
            "priority": "high",
            "content_available": true // Bu, uygulamanın arka planda uyanmasını sağlar
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("❌ FCM Payload Error: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("❌ FCM Request Error: \(error.localizedDescription)")
            } else {
                print("✅ FCM Notification Sent Successfully!")
            }
        }
        task.resume()
    }
}
