//
//  NotifiesViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation

protocol NotifiesViewModelInputProtocol: AnyObject {
    func viewDidLoad()
    func selectNotification(at index: Int)
}

protocol NotifiesViewModelOutputProtocol: AnyObject {
    func didFetchNotifications(with notifications: [NotificationModel])
    func didFail(with error: String)
    func didSelectCallRoom(profile: PublisherProfile, isVideo: Bool, callId: String)
}

final class NotifiesViewModel: NotifiesViewModelInputProtocol {
    
    weak var output: NotifiesViewModelOutputProtocol?
    private let firestoreService: FirestoreServiceProtocol
    var notifications: [NotificationModel] = []
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService.shared) {
        self.firestoreService = firestoreService
    }
    
    func viewDidLoad() {
        fetchNotifications()
    }
    
    func selectNotification(at index: Int) {
        guard index < notifications.count else { return }
        let notification = notifications[index]
        
        // If it's a call-related notification, navigate to Call Screen
        if let callId = notification.callId {
            let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
            
            // Map notification metadata to a profile for the CallViewController
            let otherPersonId = (userType == "guide") ? notification.watcherId : notification.publisherId
            
            let tempProfile = PublisherProfile(
                id: otherPersonId,
                about: nil,
                age: nil,
                email: nil,
                language: nil,
                last_seen: nil,
                msgToken: nil,
                name: notification.name,
                phoneNumber: notification.phone,
                point: 0,
                profilePic: notification.image,
                status: "Online",
                interests: [],
                tagList: []
            )
            
            output?.didSelectCallRoom(profile: tempProfile, isVideo: !(notification.isVoiceOnly ?? false), callId: callId)
        }
    }
    
    private func fetchNotifications() {
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        
        // Update handling logic
        let completion: (Result<[NotificationModel], Error>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let notifs):
                    let sorted = notifs.sorted(by: { ($0.timestamp ?? Date.distantPast) > ($1.timestamp ?? Date.distantPast) })
                    self?.notifications = sorted
                    self?.output?.didFetchNotifications(with: sorted)
                    
                case .failure(let error):
                    self?.output?.didFail(with: error.localizedDescription)
                }
            }
        }
        
        if userType == "guide" {
            firestoreService.fetchPublisherNotifications(completion: completion)
        } else {
            firestoreService.fetchWatcherNotifications(completion: completion)
        }
    }
}
