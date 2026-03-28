//
//  NotifiesViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation

protocol NotifiesViewModelInputProtocol: AnyObject {
    func viewDidLoad()
}

protocol NotifiesViewModelOutputProtocol: AnyObject {
    func didFetchNotifications(with notifications: [NotificationModel])
    func didFail(with error: String)
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
    
    private func fetchNotifications() {
        firestoreService.fetchNotifications { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let notifs):
                    self?.notifications = notifs
                    self?.output?.didFetchNotifications(with: notifs)
                case .failure(let error):
                    self?.output?.didFail(with: error.localizedDescription)
                }
            }
        }
    }
}
