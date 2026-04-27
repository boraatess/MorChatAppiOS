//
//  AppDelegate.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications
import IQKeyboardManagerSwift
import FirebaseAuth
import SwiftUI
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var scene: UIWindowScene?
    var appCoordinator: AppCoordinator?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        FirebaseApp.configure()
        CallManager.shared.start()
        CoinManager.shared.start()
        
        MobileAds.shared.start(completionHandler: nil)
        
        
        // Fetch all tags globally so they can be mapped
        TagManager.shared.fetchTags()
        
        // --- KEYBOARD MANAGER SETUP ---
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.enableAutoToolbar = true // Toolbar (Done butonu) aktif
        IQKeyboardManager.shared.resignOnTouchOutside = true // Dışarı basınca kapat
        // IQKeyboardManager.shared.toolbarConfiguration.doneBarButtonConfiguration?.title = "Tamam" // Buton metni
        
        // --- PUSH NOTIFICATIONS SETUP ---
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        return true
    }


    func application(
          _ application: UIApplication,
          configurationForConnecting connectingSceneSession: UISceneSession,
          options: UIScene.ConnectionOptions
      ) -> UISceneConfiguration {

          UISceneConfiguration(
              name: "Default Configuration",
              sessionRole: connectingSceneSession.role
          )
      }
 
    

}

// MARK: - UNUserNotificationCenterDelegate & MessagingDelegate
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("✅ Firebase FCM Token: \(token)")
        
        UserDefaults.standard.set(token, forKey: "fcm_token")
        let auth = Auth.auth()
        // Ensure user is logged in
        if auth.currentUser != nil {
            FirestoreService.shared.updateFCMToken(token: token)
        }
    }

    
    // When notification arrives while app is in FOREGROUND
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show banner and play sound even if app is open
        completionHandler([.banner, .sound, .badge])
    }
    
    // When user TAPS on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("📲 Notification tapped with user info: \(userInfo)")
        
        // Handle navigation based on notification data here if needed
        
        completionHandler()
    }

    // Handle background notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("📩 Remote notification received in background: \(userInfo)")
        
        // Eğer bu bir arama bildirimi ise CallKit tetiklenebilir
        
        completionHandler(.newData)
    }
}
