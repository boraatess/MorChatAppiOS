//
//  RewardedAdManager.swift
//  MorChatApp
//
//  Created by bora ateş on 24.04.2026.
//

import Foundation
import GoogleMobileAds
import UIKit

// apple -> ca-app-pub-3066798903065241~9105470064
// ca-app-pub-3066798903065241/6507226885


import GoogleMobileAds
import FirebaseFirestore
import FirebaseAuth

class RewardedAdManager: NSObject {
    
    private var rewardedAd: RewardedAd?
    private let db = Firestore.firestore()
    private let dailyLimit = 5
    
    // MARK: - Reklamı Yükle
    func loadAd() {
        let request = Request()
        RewardedAd.load(
            with: "ca-app-pub-3066798903065241/6507226885",
            request: request
        ) { ad, error in
            if let error = error {
                print("Reklam yüklenemedi: \(error.localizedDescription)")
                return
            }
            self.rewardedAd = ad
            print("Reklam yüklendi!")
        }
    }
    
    // MARK: - Günlük Limit Kontrolü
    func checkDailyLimit(completion: @escaping (Bool, String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "Kullanıcı bulunamadı")
            return
        }
        
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                completion(false, "Kullanıcı verisi alınamadı")
                return
            }
            
            let adsWatchedTotal = data["adsWatchedTotal"] as? Int ?? 0
            let lastAdWatchedTime = data["lastAdWatchedTime"] as? Int64 ?? 0
            
            // lastAdWatchedTime bugüne mi ait?
            let lastDate = Date(timeIntervalSince1970: TimeInterval(lastAdWatchedTime))
            let isToday = Calendar.current.isDateInToday(lastDate)
            
            if isToday {
                // Bugün izlenen reklam sayısını hesapla
                if adsWatchedTotal >= self.dailyLimit {
                    completion(false, "Günlük 5 reklam limitine ulaştınız. Yarın tekrar deneyin!")
                } else {
                    completion(true, "")
                }
            } else {
                // Farklı gün → sıfırla
                userRef.updateData(["adsWatchedTotal": 0]) { _ in
                    completion(true, "")
                }
            }
        }
    }
    
    // MARK: - Reklamı Göster
    func showAd(from viewController: UIViewController, completion: @escaping (Bool, String) -> Void) {
        
        checkDailyLimit { canWatch, message in
            guard canWatch else {
                completion(false, message)
                return
            }
            
            guard let rewardedAd = self.rewardedAd else {
                completion(false, "Reklam henüz yüklenmedi, lütfen bekleyin")
                return
            }
            
            DispatchQueue.main.async {
                rewardedAd.present(from: viewController) {
                    self.giveReward()
                    completion(true, "")
                }
            }
        }
    }
    
    // MARK: - Ödül Ver ve Firebase Güncelle
    private func giveReward() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userId)
        let now = Int64(Date().timeIntervalSince1970)
        
        userRef.getDocument { snapshot, _ in
            let currentCredits = snapshot?.data()?["creditCount"] as? Int ?? 0
            let currentAdsWatched = snapshot?.data()?["adsWatchedTotal"] as? Int ?? 0
            
            userRef.updateData([
                "creditCount": currentCredits + 10,      // 10 jeton ekle
                "adsWatchedTotal": currentAdsWatched + 1, // izleme sayısını artır
                "lastAdWatchedTime": now                  // zamanı güncelle
            ])
            
            // Yeni reklamı önceden yükle
            self.loadAd()
        }
    }
}
