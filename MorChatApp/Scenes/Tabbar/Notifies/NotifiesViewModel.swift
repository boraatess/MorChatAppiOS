import Foundation
import FirebaseFirestore
import FirebaseAuth

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
    private var notifyListener: ListenerRegistration?
    var notifications: [NotificationModel] = []
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService.shared) {
        self.firestoreService = firestoreService
    }
    
    deinit {
        notifyListener?.remove()
    }
    
    func viewDidLoad() {
        startListeningNotifications()
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
            
            print("👉 Notifications: Bildirim seçildi. Hedef Kişi ID: \(otherPersonId ?? "nil"), Arama ID: \(callId)")
            
            output?.didSelectCallRoom(profile: tempProfile, isVideo: !(notification.isVoiceOnly ?? false), callId: callId)
        }
    }
    
    private func startListeningNotifications() {
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        let currentUid = (FirebaseAuth.Auth.auth().currentUser?.uid) ?? "Giriş Yapılmamış"
        
        print("🔍 Notifications: Dinleme başlatılıyor...")
        print("🔍 Notifications: Kullanıcı ID: \(currentUid)")
        print("🔍 Notifications: Kullanıcı Tipi (userType): \(userType)")
        
        notifyListener?.remove()
        
        let completion: (Result<[NotificationModel], Error>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let notifs):
                    print("✅ Notifications: \(notifs.count) adet bildirim başarıyla işlendi.")
                    let sorted = notifs.sorted(by: { ($0.timestamp ?? Date.distantPast) > ($1.timestamp ?? Date.distantPast) })
                    self?.notifications = sorted
                    self?.output?.didFetchNotifications(with: sorted)
                    
                case .failure(let error):
                    print("❌ Notifications: Hata oluştu: \(error.localizedDescription)")
                    self?.output?.didFail(with: error.localizedDescription)
                }
            }
        }
        
        if userType == "guide" {
            print("🚀 Notifications: 'NotificationListPublisher' koleksiyonu dinleniyor...")
            notifyListener = firestoreService.listenPublisherNotifications(completion: completion)
        } else {
            print("🚀 Notifications: 'NotificationListWatcher' koleksiyonu dinleniyor...")
            notifyListener = firestoreService.listenWatcherNotifications(completion: completion)
        }
    }
    
    
}
