//
//  PublisherServices.swift
//  MorChatApp
//
//  Created by bora ateş on 31.03.2026.
//

import Foundation

protocol PublisherServicesProtocol {
    func fetchPublisherProfiles(completion: @escaping (Result<[PublisherProfile], Error>) -> Void)
    func fetchPublisherProfile(publisherId: String, completion: @escaping (Result<PublisherProfile, Error>) -> Void)
   //  func fetchNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func fetchLikedPublishers(completion: @escaping (Result<[PublisherProfile], Error>) -> Void)
    func savePublisherProfile(profile: PublisherProfile, completion: @escaping (Error?) -> Void)
}

class PublisherServices: PublisherServicesProtocol {

    // Burada sınıf bir protokole (FirestoreManagerProtocol) güvenir, doğrudan manager'a değil.
      
    private let firestore: FirestoreManagerProtocol
       
    // Varsayılan değer olarak Singleton'ı veririz, ama testlerde bunu değiştirebilirsiniz.
    init(firestore: FirestoreManagerProtocol = FirestoreManager.shared) {
        self.firestore = firestore
    }
    
    // Tüm yayıncı profillerini çekme
    func fetchPublisherProfiles(completion: @escaping (Result<[PublisherProfile], Error>) -> Void) {
        firestore.fetch(from: "PublisherProfile", completion: completion)
    }
    
    // Tek bir yayıncı profilini ID ile çekme
    func fetchPublisherProfile(publisherId: String, completion: @escaping (Result<PublisherProfile, Error>) -> Void) {
        firestore.fetchDocument(from: "PublisherProfile", id: publisherId, completion: completion)
    }
    
    // Favori yayıncıları çekme (Bu biraz daha kompleks bir mantık gerektirebilir,
    // ama jenerik yapı burayı da kolaylaştırır)
    func fetchLikedPublishers(completion: @escaping (Result<[PublisherProfile], Error>) -> Void) {
        // Favori ID listesini alıp sonra profilleri çekme mantığı buraya gelir
        
    }
    
    // Profili kaydetme
    func savePublisherProfile(profile: PublisherProfile, completion: @escaping (Error?) -> Void) {
        firestore.save(data: profile, in: "PublisherProfile", id: profile.id, completion: completion)
    }
    
    
}
