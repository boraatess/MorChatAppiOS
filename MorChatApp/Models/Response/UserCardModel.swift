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
    
    let profile: PublisherProfile // 🔥 BU ŞART
    
}
