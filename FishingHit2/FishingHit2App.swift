import SwiftUI

@main
struct FishingHit2App: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(FishingHitDelegate.self) var fishingHitDelegate
    // @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .onOpenURL { url in
                    NotificationCenter.default.post(name: Notification.Name("share_deeplink"), object: nil, userInfo: ["deeplink": url.absoluteString])
                }
//            if !hasSeenOnboarding {
//                OnboardingView()
//                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                    .preferredColorScheme(.dark)
//            } else {
//                ContentView()
//                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                    .preferredColorScheme(.dark)
//            }
        }
    }
}
