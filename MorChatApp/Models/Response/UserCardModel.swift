//
//  UserCardModel.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit

struct UserCardModel {
    let name: String
    let age: Int?
    let imageURL: String?
    let status: String?
    let tags: [Int]
    let interests: [String]
    
    var profile: PublisherProfile? // Could be nil for watchers
    var user: UserModel? // Could be nil for publishers
    
    // 🔥 Anasayfa için ID'leri string etiketlere ve ilgi alanlarına döndürür
    var mappedTags: [String] {
        if let profile = profile {
            return profile.mappedTagNames
        } else if let user = user {
            return user.mappedTagNames
        } else {
            return TagManager.shared.getTagNames(fromIntIds: tags)
        }
    }
    
    var mappedInterests: [String] {
        if let user = user {
            return user.mappedInterestNames
        } else {
            return TagManager.shared.getTagNames(fromStringIds: interests)
        }
    }
}
