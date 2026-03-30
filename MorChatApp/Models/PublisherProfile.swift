import Foundation
import FirebaseFirestore

struct PublisherProfile {
    var id: String?
    let about: String?
    let age: Int?
    let email: String?
    let language: String?
    let last_seen: Date? // Timestamp to Date
    let msgToken: String?
    let name: String?
    let phoneNumber: String?
    let point: Int?
    let profilePic: String?
    let status: String?
    let interests: [String]?
    let tagList: [Int]?
}
