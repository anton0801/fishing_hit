import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
    OnboardingView()
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isTextVisible = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showAddCatch = false
    @State private var remindLater = false
    
    let pages: [OnboardingPage] = [
            OnboardingPage(
                animationName: "fish-swimming",
                title: "Welcome to Fishing Hit Base",
                description: "Your ultimate fishing companion with tools to track, learn, and master your fishing adventures."
            ),
            OnboardingPage(
                animationName: "map-pin",
                title: "Interactive Fishing Map",
                description: "Mark and explore fishing spots with filters for fish and water types."
            ),
            OnboardingPage(
                animationName: "diary-book",
                title: "Fishing Diary",
                description: "Log every catch with photos, notes, and details—view them anytime."
            ),
            OnboardingPage(
                animationName: "fish-guide",
                title: "Fish Guide",
                description: "Discover 100 fish species with habitats, baits, and seasons."
            )
        ]
    
    var body: some View {
        ZStack {
            Color.seaDark.edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], isTextVisible: isTextVisible, isLastPage: index == pages.count - 1, showAddCatch: $showAddCatch)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                ProgressView(value: Float(currentPage + 1), total: Float(pages.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    .padding(.horizontal, 40)
                
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentPage += 1
                            isTextVisible = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    isTextVisible = true
                                }
                            }
                        }
                    } else {
                        hasSeenOnboarding = true
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.seaDark)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                if currentPage < pages.count - 1 {
                    Button("Skip, Remind Later") {
                        remindLater = true
                        scheduleReminder()
                        hasSeenOnboarding = true
                    }
                    .font(.caption)
                    .foregroundColor(.turquoise)
                    .padding(.top, 10)
                }
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                isTextVisible = true
            }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
        .sheet(isPresented: $showAddCatch) {
            AddCatchView()
        }
    }
    
    private func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Continue Learning Fishing Hit"
        content.body = "Return to explore all features in 3 days!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error)")
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isTextVisible: Bool
    let isLastPage: Bool
    @Binding var showAddCatch: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            LottieView(animationName: page.animationName)
                .frame(width: 300, height: 300)
                .transition(.scale)
            
            Text(page.title)
                .font(.title)
                .foregroundColor(.turquoise)
                .opacity(isTextVisible ? 1 : 0)
                .offset(y: isTextVisible ? 0 : -20)
                .animation(.easeInOut(duration: 0.5), value: isTextVisible)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .opacity(isTextVisible ? 1 : 0)
                .offset(y: isTextVisible ? 0 : 20)
                .animation(.easeInOut(duration: 0.5).delay(0.2), value: isTextVisible)
            
            if isLastPage {
                Button("Add Your First Catch") {
                    showAddCatch = true
                }
                .font(.headline)
                .padding()
                .background(Color.turquoise)
                .foregroundColor(.seaDark)
                .cornerRadius(10)
            }
            
            Spacer()
        }
    }
}

struct OnboardingPage {
    let animationName: String
    let title: String
    let description: String
}
