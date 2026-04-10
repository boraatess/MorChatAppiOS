//
//  FirestoreManager.swift
//  MorChatApp
//
//  Created by bora ateş on 31.03.2026.
//

import Foundation
import Foundation
import FirebaseFirestore


protocol FirestoreSharedProtocol {
    // Protokol sadece "sharedManager adında bir değişken olmalı ve tipi FirestoreManager olmalı" der.
    var sharedManager: FirestoreManager { get }
}


protocol FirestoreManagerProtocol {
    func fetch<T: Codable>(from collection: String, completion: @escaping (Result<[T], Error>) -> Void)
    func fetchDocument<T: Codable>(from collection: String, id: String, completion: @escaping (Result<T, Error>) -> Void)
    func save<T: Codable>(data: T, in collection: String, id: String?, completion: @escaping (Error?) -> Void)
}

final class FirestoreManager: FirestoreManagerProtocol {
    
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    // 1. Generic Fetch (Bir koleksiyondaki tüm verileri çeker)
    func fetch<T: Codable>(from collection: String, completion: @escaping (Result<[T], Error>) -> Void) {
        db.collection(collection).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // FirebaseFirestoreSwift sayesinde otomatik Decodable
            let items = snapshot?.documents.compactMap { doc -> T? in
                try? doc.data(as: T.self)
            } ?? []
            
            completion(.success(items))
        }
    }

    // 2. Generic Fetch Document (Tek bir döküman çeker)
    func fetchDocument<T: Codable>(from collection: String, id: String, completion: @escaping (Result<T, Error>) -> Void) {
        db.collection(collection).document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                if let item = try snapshot?.data(as: T.self) {
                    completion(.success(item))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    // 3. Generic Save/Update
    func save<T: Codable>(data: T, in collection: String, id: String? = nil, completion: @escaping (Error?) -> Void) {
        let docRef = (id != nil) ? db.collection(collection).document(id!) : db.collection(collection).document()
        
        do {
            try docRef.setData(from: data, merge: true, completion: completion)
        } catch {
            completion(error)
        }
    }
}
