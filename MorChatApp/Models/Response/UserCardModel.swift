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
    let tags: [String]
    
    var profile: PublisherProfile? // Could be nil for watchers
    var user: UserModel? // Could be nil for publishers
}
