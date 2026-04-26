import Foundation
import FirebaseFirestore

struct PublisherProfile: Codable {
    var id: String?
    var about: String?
    var age: Int?
    var email: String?
    var language: String?
    var last_seen: Date? // Timestamp to Date
    var msgToken: String?
    var name: String?
    var phoneNumber: String?
    var point: Int?
    var profilePic: String?
    var status: String?
    var tagList: [Int]?
    var photos: [String]?
    var blockedWatcherList: [[String: String]]?
    
    // 🔥 Etiket Id'lerini tag string'ine dönüştürür (TagManager kullanır)
    var mappedTagNames: [String] {
        return TagManager.shared.getTagNames(fromIntIds: tagList ?? [])
    }
}

extension PublisherProfile {
    static let mock = PublisherProfile(
        id: "mock_id",
        about: "İsmim asalet bozkıran İstanbul bahçelievler de yaşıyorum Ataköy polis karakolu amirliğinde çalışıyorum ön büro amirliği nde sizlerle güzel sohbetlerin sonucunda dal fidan olmaya geldim keyifli sohbetler dilerim",
        age: 28,
        email: "mock@test.com",
        language: "tr",
        last_seen: Date(),
        msgToken: "token",
        name: "ASALET BOZKIRAN",
        phoneNumber: "05555555555",
        point: 4,
        profilePic: "https://firebasestorage.googleapis.com/v0/b/newmorchat.firebasestorage.app/o/profile%2BnY6yg6jLHuOYhfgOwPPEIoV2kUj2?alt=media",
        status: "Away",
        tagList: [1, 2, 3],
        photos: [
            "https://firebasestorage.googleapis.com/v0/b/newmorchat.firebasestorage.app/o/profile%2BnY6yg6jLHuOYhfgOwPPEIoV2kUj2?alt=media",
            "https://firebasestorage.googleapis.com/v0/b/newmorchat.firebasestorage.app/o/profile%2BnY6yg6jLHuOYhfgOwPPEIoV2kUj2?alt=media"
        ],
        blockedWatcherList: nil
    )
    
    static let empty = PublisherProfile(id: "", about: "", age: 0, email: "", language: "", last_seen: Date(), msgToken: "", name: "", phoneNumber: "", point: 0, profilePic: "", status: "", tagList: [0], photos: [""], blockedWatcherList: nil)
}
