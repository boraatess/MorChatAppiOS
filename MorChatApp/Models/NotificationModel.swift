
import Foundation
import FirebaseFirestore

struct NotificationModel {
    var id: String?
    let callId: String?
    let image: String?
    let isVoiceOnly: Bool?
    let name: String?
    let phone: String?
    let publisherId: String?
    let timestamp: Date?
    let watcherId: String?
    
    // Computed for UI compatibility with existing cells
    var title: String? { name }
    var message: String? {
        if let isVoice = isVoiceOnly {
            return isVoice ? "Incoming Voice Call" : "Incoming Video Call"
        }
        return "New Call Request"
    }
}
