//
//  PublisherModel.swift
//  MorChatApp
//
//  Created by bora ateş on 26.04.2026.
//

import Foundation


struct PublisherModel {
    let uid: String
    var name: String?
    let email: String?
    var photoURL: String?
    let createdAt: Date
    var interests: [String]?
    var tagList: [Int]?
    var age: Int?
    var status: String?
    var photos: [String]?
    var blockedPublisherList: [[String: String]]?
    
    // 🔥 Firestore UserWatcher Tablosu ile Uyumlu Alanlar
    var creditCount: Int?
    var adsWatchedTotal: Int?
    var calledPublisherId: String?
    var isOnline: Bool?
    var language: String?
    var lastAdWatchedTime: Int64?
    var phoneNumber: String?
    var msgToken: String?
    
    // 🔥 Etiketleri TagManager ile okunabilir string'lere (isimlere) çevirir
    var mappedInterestNames: [String] {
        return TagManager.shared.getTagNames(fromStringIds: interests ?? [])
    }
    
    var mappedTagNames: [String] {
        return TagManager.shared.getTagNames(fromIntIds: tagList ?? [])
    }
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": uid,
            "name": name ?? "",
            "email": email ?? "",
            "profileImage": photoURL ?? "",
            "createdAt": createdAt,
            "tagList": tagList ?? [],
            "interests": interests ?? [],
            "age": age ?? 0,
            "status": status ?? "Online",
            "photos": photos ?? [],
            "creditCount": creditCount ?? 0,
            "adsWatchedTotal": adsWatchedTotal ?? 0,
            "calledPublisherId": calledPublisherId ?? "",
            "isOnline": isOnline ?? true,
            "language": language ?? "tr",
            "lastAdWatchedTime": lastAdWatchedTime ?? 0
        ]
        
        if let phone = phoneNumber { dict["phoneNumber"] = phone }
        if let msgToken = msgToken { dict["msgToken"] = msgToken }
        if let blocked = blockedPublisherList { dict["blockedPublisherList"] = blocked }
        
        return dict
    }
}
