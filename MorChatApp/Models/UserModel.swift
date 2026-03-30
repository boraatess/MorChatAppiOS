import Foundation

struct UserModel {
    let uid: String
    var name: String?
    let email: String?
    let photoURL: String?
    let createdAt: Date
    var interests: [String]?
    var tagList: [Int]?
    let age: Int?
    var status: String?
    
    var dictionary: [String: Any] {
        return [
            "id": uid,
            "name": name ?? "",
            "email": email ?? "",
            "profileImage": photoURL ?? "",
            "createdAt": createdAt,
            "tagList": tagList ?? [],
            "interests": interests ?? [],
            "age": age ?? 0,
            "status": status ?? "Online"
        ]
    }
}
