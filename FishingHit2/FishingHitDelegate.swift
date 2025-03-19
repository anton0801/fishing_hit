import Foundation
import SwiftUI
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport

class FishingHitDelegate: NSObject, UIApplicationDelegate, AppsFlyerLibDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NotificationCenter.default.post(name: Notification.Name("apnstoken_push"), object: nil, userInfo: [
            "apnstoken": tokenString
        ])
    }
    
    func requestNotificationPermission(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        UNUserNotificationCenter.current().delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let _ = error {
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
            }
        }
    }
    
    var deepLinkURL: URL? = nil
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Обрабатываем диплинк при открытии уже запущенного приложения
        if deepLinkURL == nil {
            deepLinkURL = url
            handleDeepLink()
            
        }
        return true
    }
    
    private func handleDeepLink() {
        NotificationCenter.default.post(name: Notification.Name("share_deeplink"), object: nil, userInfo: ["deeplink": deepLinkURL!.absoluteString])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        requestNotificationPermission(application)
        
        if deepLinkURL == nil {
            if let url = launchOptions?[.url] as? URL {
                deepLinkURL = url
                handleDeepLink()
            }
        }
        
        let shared = AppsFlyerLib.shared()
        shared.appleAppID = "6743252429"
        shared.appsFlyerDevKey = "Pq2iVom4AY6Jwf7mLwW9Uk"
        shared.delegate = self
        shared.isDebug = false
        shared.waitForATTUserAuthorization(timeoutInterval: 60)
        NotificationCenter.default.addObserver(self, selector: #selector(dnsajnasjda),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        return true
    }
    
    @objc private func dnsajnasjda() {
        let shared = AppsFlyerLib.shared()
        shared.start()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                UserDefaults.standard.set(ASIdentifierManager.shared().advertisingIdentifier.uuidString, forKey: "idfa_of_user")
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        NotificationCenter.default.post(name: Notification.Name("conversion_data"), object: nil, userInfo: [:])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let pushData = userInfo["push_id"] as? String {
            UserDefaults.standard.set(pushData, forKey: "push_id")
        }
        completionHandler()
    }
    
    func onConversionDataSuccess(_ conversionData: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name("conversion_data"), object: nil, userInfo: ["data": conversionData])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let pushData = userInfo["push_id"] as? String {
            UserDefaults.standard.set(pushData, forKey: "push_id")
        }
        completionHandler([.banner, .sound])
    }
    
}
