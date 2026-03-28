//
//  NotificationModel.swift
//  MorChatApp
//
//  Created by bora ateş.
//

import Foundation
import FirebaseFirestore

struct NotificationModel {
    var id: String?
    let title: String?
    let message: String?
    let timestamp: Date?
    let image: String? // Opsiyonel ikon veya resim URL
}
