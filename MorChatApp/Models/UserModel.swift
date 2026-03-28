import Foundation

struct UserModel {
    let uid: String
    let name: String?
    let email: String?
    let photoURL: String?
    let createdAt: Date
    
    var dictionary: [String: Any] {
        return [
            "uid": uid,
            "name": name ?? "",
            "email": email ?? "",
            "photoURL": photoURL ?? "",
            "createdAt": createdAt
        ]
    }
}
