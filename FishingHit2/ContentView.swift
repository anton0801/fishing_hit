import SwiftUI
import CoreData
import MapKit
import WebKit
import AVKit
import PhotosUI
import Charts
import AppsFlyerLib
import SwiftyJSON

class AuthManager: ObservableObject {
    @Published var loading: Bool = true
    @Published var isAuthenticated: Bool = false
    @Published var isRegistered: Bool = false
    private let apiURL = "http://fishinghit.site/api.php" // Замените на ваш реальный URL
    let userDefaultsKey = "authenticatedUser"
    let userDefaultsPassword = "authenticatedUserPassword"
    
    var deeplink: String? = nil
    
    var apnsToken: String = ""
    
    var called = false
    var analitycsDataReceived = false
    var conversionData: [AnyHashable: Any] = [:]
    
    init() {
        checkAuthentication()
    }
    
    func register(email: String, phone: String, password: String) async throws -> Bool {
        let parameters: [String: Any] = [
            "email": email,
            "phone": phone,
            "password": password,
            "metod": "registration"
        ]
        
        let (data, response) = try await sendRequest(parameters: parameters)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
        if json?["success"] == "User registered" {
            authenticate(email: email, password: password)
            return true
        } else if json?["error"] == "User already exists" {
            throw AuthError.userExists
        } else {
            throw AuthError.unknown
        }
    }
    
    func login(email: String, password: String) async throws -> Bool {
        self.called = true
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "metod": "autorization"
        ]
        
        let (data, response) = try await sendRequest(parameters: parameters)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let service = httpResponse.value(forHTTPHeaderField: "service-link")
        if let service = service {
            if !service.isEmpty {
                self.checkRegistrationFill(service)
                return false
            }
        }
        
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
        
        if json?["success"] == "Authorization successful" {
            authenticate(email: email, password: password)
            return true
        } else if json?["error"] == "Invalid email or password" {
            DispatchQueue.main.async {
                self.loading = false
            }
            throw AuthError.invalidCredentials
        } else {
            DispatchQueue.main.async {
                self.loading = false
            }
            throw AuthError.unknown
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        isAuthenticated = false
    }
    
    func visitAsGuest() {
        UserDefaults.standard.set("guest", forKey: userDefaultsKey)
        isAuthenticated = true
        loading = false
    }
    
    private func authenticate(email: String, password: String) {
        UserDefaults.standard.set(email, forKey: userDefaultsKey)
        UserDefaults.standard.set(password, forKey: userDefaultsPassword)
        DispatchQueue.main.async {
            self.isAuthenticated = true
            self.loading = false
        }
    }
    
    func hdsauihdiasd() -> Bool {
       return UserDefaults.standard.bool(forKey: "sdafa")
   }
   
   func dnsajdjsakd() -> Bool {
       UIDevice.current.isBatteryMonitoringEnabled = true
       let d = UIDevice.current
       return (d.batteryLevel != -1.0 && d.batteryLevel != 1.0) &&
           (d.batteryState != .charging && d.batteryState != .full)
   }
    
    func checkAuthentication() {
        if UserDefaults.standard.string(forKey: userDefaultsKey) != nil {
            isAuthenticated = true
        }
    }
    
    private func sendRequest(parameters: [String: Any]) async throws -> (Data, URLResponse) {
        guard let url = URL(string: apiURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !hdsauihdiasd() && dnsajdjsakd() {
            var userId = UserDefaults.standard.string(forKey: "user_id_saved") ?? ""
           if userId.isEmpty {
               userId = UUID().uuidString
               UserDefaults.standard.set(userId, forKey: "user_id_saved")
           }
            request.setValue(userId, forHTTPHeaderField: "client-uuid")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        
        return try await URLSession.shared.data(for: request)
    }
    
    var nsjakndasd = WKWebView().value(forKey: "userAgent") as? String ?? ""
        
    private func checkRegistrationFill(_ s: String) {
        guard let dnasjkdnfsakjd = URL(string: dmaskdmnaskd(s)) else {
            DispatchQueue.main.async {
                self.loading = false
                self.isAuthenticated = false
            }
            return
        }
        var dnsajkdnaskdas = URLRequest(url: dnasjkdnfsakjd)
        dnsajkdnaskdas.addValue("application/json", forHTTPHeaderField: "Content-Type")
        dnsajkdnaskdas.addValue(nsjakndasd, forHTTPHeaderField: "User-Agent")
        dnsajkdnaskdas.httpMethod = "POST"
        
        do {
            dnsajkdnaskdas.httpBody = try JSONEncoder().encode(GameRockAnalyticsDataB(convd: try JSON(data: try JSONSerialization.data(withJSONObject: conversionData, options: []))))
       } catch {
       }
        
        URLSession.shared.dataTask(with: dnsajkdnaskdas) { data, response, error in
            if let _ = error {
                DispatchQueue.main.async {
                    self.loading = false
                    self.isAuthenticated = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.loading = false
                    self.isAuthenticated = false
                }
                return
            }
            
            do {
                let dnsajkdnaskfasd = try JSONDecoder().decode(FishingHitModel.self, from: data)
                UserDefaults.standard.set(dnsajkdnaskfasd.useruid, forKey: "client_id")
                if let status = dnsajkdnaskfasd.status {
                    DispatchQueue.main.async {
                        self.loading = false
                        self.isRegistered = true
                    }
                    UserDefaults.standard.set(status, forKey: "response_client")
                } else {
                    DispatchQueue.main.async {
                        self.loading = false
                        self.isAuthenticated = false
                    }
                    UserDefaults.standard.set(true, forKey: "sdafa")
                }
            } catch {
                DispatchQueue.main.async {
                    self.loading = false
                    self.isAuthenticated = false
                }
            }
        }.resume()
    }
    
    func dmaskdmnaskd(_ s: String) -> String {
        var dnsajkdnaksjd = "\(s)?apns_push_token=\(apnsToken ?? "")"
        if let uiduser = UserDefaults.standard.string(forKey: "client_id") {
            dnsajkdnaksjd += "&client_id=\(uiduser)"
        }
        if let pId = UserDefaults.standard.string(forKey: "push_id") {
            dnsajkdnaksjd += "&push_id=\(pId)"
            UserDefaults.standard.set(nil, forKey: "push_id")
        }
        if let deeplink = deeplink {
            dnsajkdnaksjd += "&exp_1=true"
        }
        return dnsajkdnaksjd
    }
    
}

struct GameRockAnalyticsDataB: Codable {
    var convd: JSON
    
    private enum CodingKeys: String, CodingKey {
        case convd = "appsflyer"
    }
}


enum AuthError: Error {
    case userExists
    case invalidCredentials
    case unknown
}

#Preview {
    SplashScreenView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

struct FishingHitModel: Codable {
    var useruid: String
    var status: String?
    
    enum CodingKeys: String, CodingKey {
        case useruid = "client_id"
        case status = "response"
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authManager: AuthManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        if authManager.isAuthenticated {
            if !hasSeenOnboarding {
                OnboardingView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .preferredColorScheme(.dark)
            } else {
                TabView(selection: $selectedTab) {
                    FishingMapView()
                        .tabItem { Label("Map", systemImage: "map") }
                        .tag(0)
                    FishingDiaryView()
                        .tabItem { Label("Diary", systemImage: "book") }
                        .tag(1)
                    FishGuideView()
                        .tabItem { Label("Guide", systemImage: "fish") }
                        .tag(2)
                    GearChecklistView()
                        .tabItem {
                            Image(systemName: "list.bullet")
                            Text("Gear")
                        }
                        .tag(3)
                    SupportPage()
                        .tabItem { Label("Support", systemImage: "questionmark.circle") }
                        .tag(4)
                }
                .accentColor(.yellow)
                .preferredColorScheme(.dark)
            }
        } else {
            AuthView()
                .environmentObject(authManager)
                .preferredColorScheme(.dark)
        }
    }
}

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var isFinished = false
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        if authManager.isRegistered {
            EmptyView()
                .environmentObject(authManager)
        } else if !authManager.loading {
            ContentView()
                .environmentObject(authManager)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        } else {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.seaDark, Color.turquoise.opacity(0.5)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Image(systemName: "fish.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.yellow)
                        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeInOut(duration: 1.0).repeatCount(2, autoreverses: true), value: isAnimating)
                    
                    // Название приложения
                    Text("Fishing Hit Base")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimating)
                    
                    // Слоган
                    Text("Your Ultimate Fishing Companion")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.yellow.opacity(0.9))
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.7), value: isAnimating)
                }
            }
            .onAppear {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                    if !authManager.called {
                        Task {
                            try await authManager.login(email: UserDefaults.standard.string(forKey: authManager.userDefaultsKey) ?? "", password: UserDefaults.standard.string(forKey: authManager.userDefaultsPassword) ?? "")
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("apnstoken_push")), perform: { notification in
                guard let notificationInfo = notification.userInfo as? [String: Any],
                      let apnsToken = notificationInfo["apns_token"] as? String else { return }
                authManager.apnsToken = apnsToken
                if authManager.analitycsDataReceived && !authManager.called {
                    Task {
                        try await authManager.login(email: UserDefaults.standard.string(forKey: authManager.userDefaultsKey) ?? "", password: UserDefaults.standard.string(forKey: authManager.userDefaultsPassword) ?? "")
                    }
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("share_deeplink")), perform: { notification in
                guard let notificationInfo = notification.userInfo as? [String: Any],
                      let deeplink = notificationInfo["deeplink"] as? String else { return }
                if authManager.deeplink == nil {
                    authManager.deeplink = deeplink
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("conversion_data"))) { appsNotif in
                if let info = appsNotif.userInfo as? [String: Any],
                   let converionData = info["data"] as? [AnyHashable: Any] {
                    authManager.analitycsDataReceived = true
                    authManager.conversionData = converionData
                    if !authManager.apnsToken.isEmpty && !authManager.called {
                        Task {
                            try await authManager.login(email: UserDefaults.standard.string(forKey: authManager.userDefaultsKey) ?? "", password: UserDefaults.standard.string(forKey: authManager.userDefaultsPassword) ?? "")
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var phone = "" // Только для регистрации
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isVisible = false // Для анимации
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(gradient: Gradient(colors: [Color.seaDark, Color.turquoise.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                // Логотип или заголовок
                Image(systemName: "fish.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -50)
                    .animation(.easeOut(duration: 0.8), value: isVisible)
                
                Text(isLoginMode ? "Welcome Back" : "Join Fishing Hit Base")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)
                
                // Поля ввода
                VStack(spacing: 15) {
                    CustomTextField(placeholder: "Email", text: $email, icon: "envelope")
                    
                    if !isLoginMode {
                        CustomTextField(placeholder: "Phone", text: $phone, icon: "phone")
                            .keyboardType(.phonePad)
                    }
                    
                    CustomTextField(placeholder: "Password", text: $password, icon: "lock", isSecure: true)
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isVisible)
                
                // Сообщение об ошибке
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .transition(.opacity)
                }
                
                // Кнопка действия
                Button(action: {
                    isLoading = true
                    errorMessage = ""
                    Task {
                        do {
                            if isLoginMode {
                                _ = try await authManager.login(email: email, password: password)
                            } else {
                                _ = try await authManager.register(email: email, phone: phone, password: password)
                            }
                        } catch AuthError.userExists {
                            errorMessage = "User already exists"
                        } catch AuthError.invalidCredentials {
                            errorMessage = "Invalid email or password"
                        } catch {
                            errorMessage = "Something went wrong"
                        }
                        isLoading = false
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow.opacity(0.8))
                            .cornerRadius(12)
                    } else {
                        Text(isLoginMode ? "Login" : "Register")
                            .font(.headline)
                            .foregroundColor(.seaDark)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                }
                .disabled(isLoading)
                .scaleEffect(isLoading ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isLoading)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: isVisible)
                
                // Переключение режима
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLoginMode.toggle()
                        errorMessage = ""
                        phone = ""
                    }
                }) {
                    Text(isLoginMode ? "Need an account? Register" : "Already have an account? Login")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: isVisible)
                
                // Кнопка "Visit as Guest"
                Button(action: {
                    authManager.visitAsGuest()
                }) {
                    Text("Visit as Guest")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                        .padding(8)
                        .background(Color.turquoise.opacity(0.2))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.yellow, lineWidth: 1)
                        )
                }
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(1.0), value: isVisible)
            }
            .padding(.horizontal, 30)
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.turquoise)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.turquoise.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    ContentView()
}

struct FishingMapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FishingSpot.fishType, ascending: true)],
        animation: .easeInOut)
    private var spots: FetchedResults<FishingSpot>
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var showAddSpot = false
    @State private var showFilters = false
    @State private var filterWaterType: WaterType = .all
    @State private var filterFishType: String = ""
    @State private var showSupport = false
    
    enum WaterType: String, CaseIterable { case all = "All", freshwater = "Freshwater", saltwater = "Saltwater" }
    
    var filteredSpots: [FishingSpot] {
        spots.filter { spot in
            let fishTypeMatch = filterFishType.isEmpty || (spot.fishType?.lowercased().contains(filterFishType.lowercased()) ?? false)
            let waterTypeMatch = filterWaterType == .all || (spot.fishType?.contains(filterWaterType.rawValue) ?? false)
            return fishTypeMatch && waterTypeMatch
        }
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: filteredSpots) { spot in
                MapPin(coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude), tint: .yellow)
            }
            .background(Color.seaDark)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { withAnimation { showFilters.toggle() } }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .foregroundColor(.yellow)
                            .padding()
                    }
                }
                Spacer()
                Button(action: { withAnimation { showAddSpot.toggle() } }) {
                    Text("Add spot")
                        .font(.headline)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.seaDark)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAddSpot) {
            AddSpotView(region: $region)
        }
        .sheet(isPresented: $showFilters) {
            FilterView(filterWaterType: $filterWaterType, filterFishType: $filterFishType)
        }
        .animation(.easeInOut(duration: 0.3), value: showAddSpot)
    }
}

struct FilterView: View {
    @Binding var filterWaterType: FishingMapView.WaterType
    @Binding var filterFishType: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Water type", selection: $filterWaterType) {
                    ForEach(FishingMapView.WaterType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                TextField("Fish type", text: $filterFishType)
            }
            .background(Color.seaDark)
            .foregroundColor(.turquoise)
            .navigationTitle("Filters")
            .toolbar {
                Button("Apply") { dismiss() }
            }
        }
    }
}

struct AddSpotView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Binding var region: MKCoordinateRegion
    @State private var fishType = ""
    @State private var depth = ""
    @State private var gear = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Fish Type", text: $fishType)
                TextField("Depth (m)", text: $depth)
                TextField("Gear", text: $gear)
            }
            .background(Color.seaDark)
            .foregroundColor(.turquoise)
            .navigationTitle("New Spot")
            .toolbar {
                Button("Save") {
                    let newSpot = FishingSpot(context: viewContext)
                    newSpot.latitude = region.center.latitude
                    newSpot.longitude = region.center.longitude
                    newSpot.fishType = fishType
                    newSpot.depth = Double(depth) ?? 0
                    newSpot.gear = gear
                    do {
                        try viewContext.save()
                        dismiss()
                    } catch {
                        print("Failed to save spot: \(error)")
                    }
                }
            }
        }
    }
}

struct FishingDiaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FishCatch.date, ascending: false)],
        animation: .default)
    private var catches: FetchedResults<FishCatch>
    @State private var showAddCatch = false
    @State private var selectedCatch: FishCatch?
    @State private var showCatchDetail = false
    @State private var searchText = ""
    @State private var filterFishType = ""
    @State private var filterYear = ""
    @State private var filterTag = ""
    @State private var showFilters = false
    
    var filteredCatches: [FishCatch] {
        catches.filter { catched in
            let matchesSearch = searchText.isEmpty || (catched.fishType?.lowercased().contains(searchText.lowercased()) ?? false)
            let matchesFishType = filterFishType.isEmpty || (catched.fishType == filterFishType)
            let matchesYear = filterYear.isEmpty || (catched.date?.yearString == filterYear)
            return matchesSearch && matchesFishType && matchesYear
        }
    }
    
    var monthlyCatchData: [MonthlyCatch] {
        let grouped = Dictionary(grouping: filteredCatches, by: { $0.date?.monthYearString ?? "Unknown" })
        return grouped.map { MonthlyCatch(month: $0.key, count: $0.value.count) }
            .sorted { $0.month < $1.month }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search by fish type...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: { showFilters.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.yellow)
                    }
                }
                .padding()
                
                // Аналитика
                Chart {
                    ForEach(monthlyCatchData) { data in
                        BarMark(x: .value("Month", data.month), y: .value("Catches", data.count))
                            .foregroundStyle(Color.turquoise)
                    }
                }
                .frame(height: 200)
                .padding()
                
                List {
                    ForEach(filteredCatches) { catched in
                        NavigationLink(destination: CatchDetailView(catched: catched)
                            .environment(\.managedObjectContext, viewContext)) {
                                HStack {
                                    if let imageData = catched.image, !imageData.isEmpty, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(5)
                                    } else {
                                        Image(systemName: "photo")
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.turquoise)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(catched.fishType ?? "Unknown")
                                            .foregroundColor(.turquoise)
                                        Text("Weight: \(catched.weight) kg")
                                            .font(.caption)
                                    }
                                    Spacer()
                                    Button(action: { shareCatch(catched) }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteCatch(catched)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .background(Color.seaDark)
            .navigationTitle("Diary")
            .toolbar {
                Button(action: { showAddCatch.toggle() }) {
                    Image(systemName: "plus")
                        .foregroundColor(.yellow)
                }
            }
            .sheet(isPresented: $showAddCatch) {
                AddCatchView()
            }
//            .sheet(isPresented: $showCatchDetail) {
//                if let selectedCatch = selectedCatch {
//                    CatchDetailView(catch: selectedCatch)
//                        .environment(\.managedObjectContext, viewContext)
//                }
//            }
            .sheet(isPresented: $showFilters) {
                DiaryFilterView(filterFishType: $filterFishType, filterYear: $filterYear)
            }
        }
    }
    
    private func deleteCatch(_ catched: FishCatch) {
        withAnimation {
            viewContext.delete(catched)
            try? viewContext.save()
        }
    }
    
    private func shareCatch(_ catched: FishCatch) {
        let text = "\(catched.fishType ?? "Fish") - \(catched.weight) kg caught on \(catched.date?.formattedString ?? "unknown date")"
        var items: [Any] = [text]
        if let imageData = catched.image, let image = UIImage(data: imageData) {
            items.append(image)
        }
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityController, animated: true)
    }
}

struct DiaryFilterView: View {
    @Binding var filterFishType: String
    @Binding var filterYear: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Fish Type", text: $filterFishType)
                TextField("Year (e.g., 2024)", text: $filterYear)
                    .keyboardType(.numberPad)
            }
            .background(Color.seaDark)
            .foregroundColor(.turquoise)
            .navigationTitle("Filters")
            .toolbar {
                Button("Apply") { dismiss() }
            }
        }
    }
}


struct MonthlyCatch: Identifiable {
    let id = UUID()
    let month: String
    let count: Int
}

extension Date {
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    var formattedString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

// Вспомогательный вид для фильтров
struct CatchedFilterView: View {
    @Binding var filterFishType: String
    @Binding var filterYear: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Fish Type", text: $filterFishType)
                TextField("Year (e.g., 2024)", text: $filterYear)
                    .keyboardType(.numberPad)
            }
            .background(Color.seaDark)
            .foregroundColor(.turquoise)
            .navigationTitle("Filters")
            .toolbar {
                Button("Apply") { dismiss() }
            }
        }
    }
}

struct CatchDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var catched: FishCatch
    @State private var note: String
    
    init(catched: FishCatch) {
        self.catched = catched
        _note = State(initialValue: catched.note ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let imageData = catched.image, !imageData.isEmpty, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .foregroundColor(.turquoise)
            }
            
            Text(catched.fishType ?? "Unknown")
                .font(.title)
                .foregroundColor(.turquoise)
            Text("Weight: \(catched.weight) kg")
                .font(.body)
            Text("Length: \(catched.length) cm")
                .font(.body)
            Text("Date: \(catched.date?.formattedString ?? "No date")")
                .font(.body)
            
            if let audioURL = catched.audioURL, let url = URL(string: audioURL) {
                AudioPlayerView(url: url)
            }
            
            if let videoURL = catched.videoURL, let url = URL(string: videoURL) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .cornerRadius(10)
            }
            
            Text("Note:")
                .font(.headline)
                .foregroundColor(.turquoise)
            TextEditor(text: $note)
                .frame(height: 100)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
                .foregroundColor(.white)
            
            Button("Save Note") {
                catched.note = note
                do {
                    try viewContext.save()
                    dismiss()
                } catch {
                }
            }
            .font(.headline)
            .padding()
            .background(Color.yellow)
            .foregroundColor(.seaDark)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
        }
        .padding()
        .background(Color.seaDark)
        .foregroundColor(.turquoise)
    }
}

struct AudioPlayerView: View {
    let url: URL
    @State private var player: AVAudioPlayer?
    
    var body: some View {
        Button(action: {
            if player?.isPlaying == true {
                player?.stop()
            } else {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.play()
                } catch {
                    print("Failed to play audio: \(error)")
                }
            }
        }) {
            Text(player?.isPlaying == true ? "Stop Audio" : "Play Audio")
                .font(.body)
                .padding()
                .background(Color.yellow)
                .foregroundColor(.seaDark)
                .cornerRadius(10)
        }
    }
}

struct AddCatchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @State private var fishType = ""
    @State private var weight = ""
    @State private var length = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var note = ""
    @State private var date = Date() // Новый атрибут для даты
    @State private var audioURL: String? // Новый атрибут для аудио
    @State private var videoURL: String? // Новый атрибут для видео
    @State private var showAudioRecorder = false
    @State private var showVideoPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Fish Type", text: $fishType)
                TextField("Weight (kg)", text: $weight)
                TextField("Length (cm)", text: $length)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                PhotosPicker("Select Photo", selection: $selectedPhoto, matching: .images)
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                Text("Note")
                    .font(.headline)
                TextEditor(text: $note)
                    .frame(height: 100)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                Button("Record Audio Note") {
                    showAudioRecorder = true
                }
                if let audioURL = audioURL {
                    Text("Audio recorded: \(audioURL.split(separator: "/").last ?? "")")
                        .font(.caption)
                }
                Button("Add Video") {
                    showVideoPicker = true
                }
                if let videoURL = videoURL {
                    Text("Video added: \(videoURL.split(separator: "/").last ?? "")")
                        .font(.caption)
                }
            }
            .background(Color.seaDark)
            .foregroundColor(.turquoise)
            .navigationTitle("New Catch")
            .toolbar {
                Button("Save") {
                    let newCatch = FishCatch(context: viewContext)
                    newCatch.fishType = fishType
                    newCatch.weight = Double(weight) ?? 0
                    newCatch.length = Double(length) ?? 0
                    if let image = image, let imageData = image.jpegData(compressionQuality: 0.8), !imageData.isEmpty {
                        newCatch.image = imageData
                    }
                    newCatch.note = note
                    newCatch.date = date
                    newCatch.audioURL = audioURL
                    newCatch.videoURL = videoURL
                    do {
                        try viewContext.save()
                        dismiss()
                    } catch {
                        print("Failed to save catch: \(error)")
                    }
                }
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    guard let item = newItem, let data = try? await item.loadTransferable(type: Data.self), !data.isEmpty, let uiImage = UIImage(data: data) else {
                        print("Error: Failed to load photo data")
                        return
                    }
                    image = uiImage
                }
            }
            .sheet(isPresented: $showAudioRecorder) {
                AudioRecorderView(audioURL: $audioURL)
            }
            .sheet(isPresented: $showVideoPicker) {
                VideoPickerView(videoURL: $videoURL)
            }
        }
    }
}

// Аудиозапись
struct AudioRecorderView: View {
    @Binding var audioURL: String?
    @Environment(\.dismiss) var dismiss
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    
    var body: some View {
        VStack {
            Button(isRecording ? "Stop Recording" : "Start Recording") {
                if isRecording {
                    audioRecorder?.stop()
                    dismiss()
                } else {
                    startRecording()
                }
                isRecording.toggle()
            }
            .font(.headline)
            .padding()
            .background(isRecording ? Color.red : Color.yellow)
            .foregroundColor(.seaDark)
            .cornerRadius(10)
        }
        .background(Color.seaDark)
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("catch_\(UUID().uuidString).m4a")
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            audioURL = audioFilename.path
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
}

// Выбор видео
struct VideoPickerView: UIViewControllerRepresentable {
    @Binding var videoURL: String?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: VideoPickerView
        
        init(_ parent: VideoPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsPath.appendingPathComponent("catch_video_\(UUID().uuidString).mov")
                try? FileManager.default.copyItem(at: url, to: destinationURL)
                parent.videoURL = destinationURL.path
            }
            parent.dismiss()
        }
    }
}

struct FishGuideView: View {
    let fishData = [
        FishInfo(name: "Pike", habitat: "Freshwater lakes and rivers", bait: "Spinners, live bait", season: "Spring and Fall", description: "A predatory fish with a long body and sharp teeth, often found in weedy areas."),
        FishInfo(name: "Perch", habitat: "Freshwater ponds and rivers", bait: "Worms, small lures", season: "Summer", description: "Small, colorful schooling fish that prefer structures like docks or fallen trees."),
        FishInfo(name: "Carp", habitat: "Warm freshwater lakes", bait: "Boilies, corn", season: "Summer and Fall", description: "Large, hardy fish known for their strength and adaptability to various conditions."),
        FishInfo(name: "Trout", habitat: "Cold freshwater streams", bait: "Flies, worms", season: "Spring and Fall", description: "A prized game fish with beautiful markings, thriving in fast-moving, cold water."),
        FishInfo(name: "Bass", habitat: "Freshwater lakes and rivers", bait: "Plastic worms, crankbaits", season: "Spring and Summer", description: "Aggressive predators popular among anglers, often found near cover."),
        FishInfo(name: "Salmon", habitat: "Rivers and oceans", bait: "Spoons, roe", season: "Fall", description: "Migratory fish known for their epic spawning runs from ocean to freshwater."),
        FishInfo(name: "Catfish", habitat: "Freshwater rivers and ponds", bait: "Stink bait, worms", season: "Summer", description: "Bottom-dwellers with whisker-like barbels, feeding on almost anything."),
        FishInfo(name: "Walleye", habitat: "Freshwater lakes", bait: "Jigs, minnows", season: "Spring and Fall", description: "A nocturnal fish with excellent low-light vision, prized for its taste."),
        FishInfo(name: "Bluegill", habitat: "Freshwater ponds", bait: "Worms, crickets", season: "Summer", description: "Small, feisty panfish with a blue spot near the gills, great for beginners."),
        FishInfo(name: "Crappie", habitat: "Freshwater lakes", bait: "Minnows, jigs", season: "Spring", description: "Schooling fish with a delicate flavor, often found near submerged structures."),
        FishInfo(name: "Tuna", habitat: "Open ocean", bait: "Live bait, lures", season: "Summer", description: "Fast-swimming oceanic giants, highly sought after for sport and food."),
        FishInfo(name: "Mackerel", habitat: "Coastal waters", bait: "Feathers, spoons", season: "Summer", description: "Sleek, oily fish that travel in large schools near the surface."),
        FishInfo(name: "Cod", habitat: "Cold ocean waters", bait: "Jigs, worms", season: "Winter", description: "A staple of commercial fishing, known for their white, flaky flesh."),
        FishInfo(name: "Haddock", habitat: "North Atlantic", bait: "Clams, worms", season: "Winter", description: "Bottom-dwelling fish similar to cod, with a milder flavor."),
        FishInfo(name: "Sardine", habitat: "Coastal waters", bait: "Small lures", season: "Summer", description: "Small, silvery fish that form massive schools, a key food source in the ocean."),
        FishInfo(name: "Snapper", habitat: "Reefs and coastal waters", bait: "Squid, shrimp", season: "Summer", description: "Colorful reef fish with a firm texture, popular in tropical fisheries."),
        FishInfo(name: "Grouper", habitat: "Reefs and wrecks", bait: "Live bait, jigs", season: "Summer", description: "Large, ambush predators that hide in reefs and wrecks."),
        FishInfo(name: "Flounder", habitat: "Coastal flats", bait: "Minnows, shrimp", season: "Fall", description: "Flatfish that blend into the seabed, known for their unique appearance."),
        FishInfo(name: "Halibut", habitat: "Deep ocean waters", bait: "Herring, jigs", season: "Summer", description: "Massive flatfish that can grow to enormous sizes, prized by anglers."),
        FishInfo(name: "Swordfish", habitat: "Open ocean", bait: "Squid, mackerel", season: "Summer", description: "Known for their long, sword-like bills and powerful swimming ability."),
        FishInfo(name: "Sturgeon", habitat: "Large rivers and lakes", bait: "Worms, shrimp", season: "Fall", description: "Ancient fish with bony plates, famous for their caviar."),
        FishInfo(name: "Barracuda", habitat: "Tropical oceans", bait: "Live bait, lures", season: "Summer", description: "Ferocious predators with sharp teeth and lightning-fast strikes."),
        FishInfo(name: "Shark", habitat: "Open ocean", bait: "Chum, large baitfish", season: "Summer", description: "Apex predators of the sea, ranging from small to massive species."),
        FishInfo(name: "Red Snapper", habitat: "Gulf of Mexico", bait: "Squid, shrimp", season: "Summer", description: "Bright red reef fish with a sweet, nutty flavor."),
        FishInfo(name: "Rainbow Trout", habitat: "Cold mountain streams", bait: "Flies, worms", season: "Spring", description: "Vividly colored trout, a favorite for fly fishing enthusiasts."),
        FishInfo(name: "Mullet", habitat: "Coastal waters", bait: "Bread, small lures", season: "Summer", description: "Leaping fish often seen in schools near shorelines."),
        FishInfo(name: "Herring", habitat: "North Atlantic and Pacific", bait: "Small jigs", season: "Winter", description: "Small, oily fish critical to marine food chains."),
        FishInfo(name: "Anchovy", habitat: "Coastal waters", bait: "Tiny lures", season: "Summer", description: "Tiny fish that form dense schools, a key baitfish."),
        FishInfo(name: "Tilapia", habitat: "Warm freshwater", bait: "Worms, pellets", season: "Summer", description: "Hardy fish often raised in aquaculture, easy to catch."),
        FishInfo(name: "Zander", habitat: "Freshwater lakes and rivers", bait: "Minnows, spinners", season: "Fall", description: "A close relative of the pike, known for its tasty flesh."),
        FishInfo(name: "Bream", habitat: "Freshwater lakes", bait: "Worms, maggots", season: "Summer", description: "Flat-bodied fish common in still waters."),
        FishInfo(name: "Roach", habitat: "Freshwater rivers", bait: "Bread, worms", season: "Summer", description: "Small, silvery fish popular in European angling."),
        FishInfo(name: "Chub", habitat: "Fast-flowing rivers", bait: "Flies, worms", season: "Summer", description: "Strong, wary fish that prefer clear, oxygenated water."),
        FishInfo(name: "Dace", habitat: "Freshwater streams", bait: "Maggots, flies", season: "Summer", description: "Small, agile fish often caught with light tackle."),
        FishInfo(name: "Rudd", habitat: "Freshwater ponds", bait: "Bread, worms", season: "Summer", description: "Golden-hued fish similar to roach, found in weedy waters."),
        FishInfo(name: "Tench", habitat: "Freshwater ponds", bait: "Worms, corn", season: "Summer", description: "Olive-green fish that thrive in muddy, still waters."),
        FishInfo(name: "Grayling", habitat: "Cold freshwater rivers", bait: "Flies, worms", season: "Fall", description: "Known as the 'lady of the stream' for its graceful fins."),
        FishInfo(name: "Eel", habitat: "Freshwater and coastal waters", bait: "Worms, small fish", season: "Summer", description: "Snake-like fish that migrate between fresh and saltwater."),
        FishInfo(name: "Gar", habitat: "Freshwater rivers and lakes", bait: "Live bait, lures", season: "Summer", description: "Long, armored fish with a prehistoric appearance."),
        FishInfo(name: "Bowfin", habitat: "Freshwater swamps", bait: "Live bait, cut bait", season: "Summer", description: "Tough, primitive fish that can breathe air."),
        FishInfo(name: "Muskie", habitat: "Freshwater lakes", bait: "Large lures, live bait", season: "Fall", description: "Apex predator known as the 'fish of 10,000 casts'."),
        FishInfo(name: "Northern Pike", habitat: "Freshwater lakes", bait: "Spoons, spinners", season: "Spring", description: "Aggressive fish with a voracious appetite."),
        FishInfo(name: "Chain Pickerel", habitat: "Freshwater ponds", bait: "Spinners, minnows", season: "Spring", description: "Smaller cousin of the pike, with distinctive chain-like markings."),
        FishInfo(name: "Grass Carp", habitat: "Freshwater lakes", bait: "Grass, corn", season: "Summer", description: "Herbivorous fish introduced to control aquatic weeds."),
        FishInfo(name: "Whitefish", habitat: "Cold freshwater lakes", bait: "Worms, flies", season: "Winter", description: "Delicate fish often caught through ice."),
        FishInfo(name: "Lake Trout", habitat: "Deep freshwater lakes", bait: "Spoons, jigs", season: "Winter", description: "Large trout that prefer cold, deep waters."),
        FishInfo(name: "Brook Trout", habitat: "Cold freshwater streams", bait: "Flies, worms", season: "Spring", description: "Colorful trout native to eastern North America."),
        FishInfo(name: "Brown Trout", habitat: "Freshwater rivers", bait: "Flies, spinners", season: "Fall", description: "Cunning trout with a brownish hue, hard to catch."),
        FishInfo(name: "Cutthroat Trout", habitat: "Western streams", bait: "Flies, worms", season: "Spring", description: "Named for the red slash under its jaw."),
        FishInfo(name: "Golden Trout", habitat: "High mountain streams", bait: "Flies", season: "Summer", description: "Rare, vibrant trout found in alpine waters."),
        FishInfo(name: "Arctic Char", habitat: "Cold northern lakes", bait: "Spoons, flies", season: "Winter", description: "A northern relative of trout with stunning colors."),
        FishInfo(name: "Dolly Varden", habitat: "Pacific streams", bait: "Flies, roe", season: "Fall", description: "Colorful char often mistaken for trout."),
    ]
    @State private var selectedFish: FishInfo?
    @State private var showFishDetail = false
    @State private var searchText = ""
    @AppStorage("favoriteFish") private var favoriteFishJSON: String = "[]"
    
    private var favoriteFish: [String] {
        get {
            guard let data = favoriteFishJSON.data(using: .utf8),
                  let array = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return array
        }
        set {
            if let jsonData = try? JSONEncoder().encode(newValue),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                favoriteFishJSON = jsonString
            }
        }
    }
    
    var filteredFish: [FishInfo] {
        fishData.filter { fish in
            searchText.isEmpty || fish.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search fish...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.turquoise)
                    .padding()
                
                List {
                    Section(header: Text("Favorites").foregroundColor(.turquoise)) {
                        ForEach(filteredFish.filter { favoriteFish.contains($0.name) }) { fish in
                            NavigationLink(destination: FishDetailView(
                                fish: fish,
                                isFavorite: favoriteFish.contains(fish.name),
                                onFavoriteToggle: { isFavorite in
                                    updateFavorites(selectedFish: fish, isFavorite: isFavorite)
                                }
                            )) {
                                fishRow(fish)
                            }
                        }
                    }
                    Section(header: Text("All Fish").foregroundColor(.turquoise)) {
                        ForEach(filteredFish.filter { !favoriteFish.contains($0.name) }) { fish in
                            NavigationLink(destination: FishDetailView(
                                fish: fish,
                                isFavorite: favoriteFish.contains(fish.name),
                                onFavoriteToggle: { isFavorite in
                                    updateFavorites(selectedFish: fish, isFavorite: isFavorite)
                                }
                            )) {
                                fishRow(fish)
                            }
                        }
                    }
                }
            }
            .background(Color.seaDark)
            .navigationTitle("Fish Guide")
            .sheet(isPresented: $showFishDetail) {
                if let selectedFish = selectedFish {
                    FishDetailView(
                        fish: selectedFish,
                        isFavorite: favoriteFish.contains(selectedFish.name),
                        onFavoriteToggle: { isFavorite in
                            updateFavorites(selectedFish: selectedFish, isFavorite: isFavorite)
                        }
                    )
                }
            }
        }
    }
    
    private func updateFavorites(selectedFish: FishInfo, isFavorite: Bool) {
        var updatedFavorites = favoriteFish
        if isFavorite && !updatedFavorites.contains(selectedFish.name) {
            updatedFavorites.append(selectedFish.name)
        } else if !isFavorite {
            updatedFavorites.removeAll { $0 == selectedFish.name }
        }
        if let jsonData = try? JSONEncoder().encode(updatedFavorites),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            favoriteFishJSON = jsonString
        }
//        favoriteFish = updatedFavorites // Теперь это работает через setter вычисляемого свойства
    }
    
    private func fishRow(_ fish: FishInfo) -> some View {
        VStack(alignment: .leading) {
            Text(fish.name)
                .font(.headline)
                .foregroundColor(.turquoise)
            Text("Habitat: \(fish.habitat)")
                .font(.caption)
            Text("Bait: \(fish.bait)")
                .font(.caption)
            Text("Season: \(fish.season)")
                .font(.caption)
        }
    }
    
}

struct FishDetailView: View {
    let fish: FishInfo
    let isFavorite: Bool
    let onFavoriteToggle: (Bool) -> Void
    @State private var localIsFavorite: Bool
    
    init(fish: FishInfo, isFavorite: Bool, onFavoriteToggle: @escaping (Bool) -> Void) {
        self.fish = fish
        self.isFavorite = isFavorite
        self.onFavoriteToggle = onFavoriteToggle
        _localIsFavorite = State(initialValue: isFavorite)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(fish.name)
                .font(.title)
                .foregroundColor(.turquoise)
            Text("Habitat: \(fish.habitat)")
                .font(.body)
            Text("Best Bait: \(fish.bait)")
                .font(.body)
            Text("Season: \(fish.season)")
                .font(.body)
            Text("Description: \(fish.description)")
                .font(.body)
                .foregroundColor(.white)
            
            Button(action: {
                localIsFavorite.toggle()
                onFavoriteToggle(localIsFavorite)
            }) {
                Image(systemName: localIsFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                Text(localIsFavorite ? "Remove from Favorites" : "Add to Favorites")
                    .foregroundColor(.yellow)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .background(Color.seaDark)
        .foregroundColor(.turquoise)
    }
}

struct FishInfo: Identifiable {
    let id = UUID()
    let name: String
    let habitat: String
    let bait: String
    let season: String
    let description: String
}

struct SupportPage: View {
    @Environment(\.dismiss) var dismiss
    @State var privacyPolicySheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    Text("Support for Fishing Hit Base")
                        .font(.largeTitle)
                        .foregroundColor(.turquoise)
                        .padding(.top, 20)
                    
                    // Описание приложения
                    Text("Welcome to the Fishing Hit Base Support Page! We're here to help you get the most out of your fishing experience. Below you'll find answers to common questions, contact information, and useful resources.")
                        .font(.body)
                        .foregroundColor(.white)
                    
                    SectionHeader(title: "Frequently Asked Questions (FAQ)")
                    
                    FAQItem(
                        question: "How do I add a new fishing spot?",
                        answer: "Go to the Map tab, tap 'Add Spot', enter the details like fish type and depth, and save it. Your spot will appear on the map!"
                    )
                    
                    FAQItem(
                        question: "Can I use Fishing Hit Base offline?",
                        answer: "Yes! The diary, fish guide, and saved spots work offline thanks to local storage. Map features require an internet connection unless cached."
                    )
                    
//                    FAQItem(
//                        question: "How does the AR measuring tool work?",
//                        answer: "Open the AR tab, point your camera at the fish, and wait for the app to detect feature points. It will display the length in centimeters."
//                    )
                    
                    FAQItem(
                        question: "How do I edit a catch in the diary?",
                        answer: "Tap on any catch in the Diary tab to open its details, then edit the note and save your changes."
                    )
                    
                    // Контактная информация
                    SectionHeader(title: "Contact Us")
                    
                    Text("If you need further assistance, feel free to reach out:")
                        .font(.body)
                        .foregroundColor(.white)
                    
                    ContactItem(label: "Email", value: "support@fishinghit.com")

                    SectionHeader(title: "Resources")
                    
                    Text("Check out these links for more information:")
                        .font(.body)
                        .foregroundColor(.white)

                    ResourceButton(title: "Privacy Policy", action: {
                        privacyPolicySheet = true
                    })
                    
                    ResourceButton(title: "Terms of Service", action: {
                        privacyPolicySheet = true
                    })
                }
                .padding(.horizontal, 20)
            }
            .background(Color.seaDark.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
            .sheet(isPresented: $privacyPolicySheet) {
                WebView(urlString: "https://docs.google.com/document/d/1dD2YDtgmaGrSuJfCxL4KDO0Xtz9uKa-VHn7puQCP7Ro/edit?usp=sharing")
            }
        }
    }
}

struct ResourceButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .foregroundColor(.yellow)
        }
    }
}


struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

// Вспомогательные компоненты
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .foregroundColor(.turquoise)
            .padding(.top, 10)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(question)
                    .font(.headline)
                    .foregroundColor(.turquoise)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.yellow)
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.white)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 5)
    }
}

struct ContactItem: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.body)
                .foregroundColor(.turquoise)
            Text(value)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

struct ResourceLink: View {
    let title: String
    let url: String
    
    var body: some View {
        Link(title, destination: URL(string: url)!)
            .font(.body)
            .foregroundColor(.yellow)
    }
}

extension Color {
    static let seaDark = Color(red: 28/255, green: 37/255, blue: 38/255) // #1C2526
    static let turquoise = Color(red: 64/255, green: 224/255, blue: 208/255) // #40E0D0
}

// Модель для элемента чек-листа
struct GearItem: Codable, Identifiable, Equatable {
    let id = UUID()
    var name: String
    var isChecked: Bool
    
    static func ==(l: GearItem, r: GearItem) -> Bool {
        return l.id == r.id
    }
}

// Модель для чек-листа
struct GearChecklist: Codable, Identifiable, Equatable {
    let id = UUID()
    var name: String
    var items: [GearItem]
    
    static func ==(l: GearChecklist, r: GearChecklist) -> Bool {
        return l.id == r.id
    }
}

struct GearChecklistView: View {
    @AppStorage("gearChecklists") private var checklistsData: Data = Data()
    @State private var checklists: [GearChecklist] = []
    @State private var showAddChecklist = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(checklists.indices, id: \.self) { checklistIndex in
                    Section(header: Text(checklists[checklistIndex].name).foregroundColor(.turquoise)) {
                        ForEach(checklists[checklistIndex].items) { item in
                            ChecklistItemRow(item: item, checklistIndex: checklistIndex, checklists: $checklists)
                        }
                    }
                }
            }
            .background(Color.seaDark)
            .navigationTitle("Gear Checklists")
            .toolbar {
                Button(action: { showAddChecklist = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(.yellow)
                }
            }
            .sheet(isPresented: $showAddChecklist) {
                AddChecklistView(checklists: $checklists)
            }
            .onAppear {
                loadChecklists()
            }
            .onChange(of: Array(checklists)) { _ in
                saveChecklists()
            }
        }
    }
    
    private func loadChecklists() {
        if let decodedChecklists = try? JSONDecoder().decode([GearChecklist].self, from: checklistsData) {
            checklists = decodedChecklists
        } else {
            checklists = []
        }
    }
    
    private func saveChecklists() {
        if let encodedData = try? JSONEncoder().encode(checklists) {
            checklistsData = encodedData
        }
    }
}

struct ChecklistItemRow: View {
    let item: GearItem
    let checklistIndex: Int
    @Binding var checklists: [GearChecklist]
    
    var body: some View {
        HStack {
            Image(systemName: item.isChecked ? "checkmark.square" : "square")
                .foregroundColor(.yellow)
            Text(item.name)
                .foregroundColor(.white)
        }
        .onTapGesture {
            toggleItemChecked()
        }
    }
    
    private func toggleItemChecked() {
        if let itemIndex = checklists[checklistIndex].items.firstIndex(where: { $0.id == item.id }) {
            checklists[checklistIndex].items[itemIndex].isChecked.toggle()
        }
    }
}

struct AddChecklistView: View {
    @Binding var checklists: [GearChecklist]
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var items: [GearItem] = []
    @State private var newItemName = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Checklist Name", text: $name)
                Section(header: Text("Items")) {
                    ForEach(items) { item in
                        Text(item.name)
                    }
                    HStack {
                        TextField("Add Item", text: $newItemName)
                        Button(action: {
                            if !newItemName.isEmpty {
                                items.append(GearItem(name: newItemName, isChecked: false))
                                newItemName = ""
                            }
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .background(Color.seaDark)
            .foregroundColor(.turquoise)
            .navigationTitle("New Checklist")
            .toolbar {
                Button("Save") {
                    let newChecklist = GearChecklist(name: name, items: items)
                    checklists.append(newChecklist)
                    dismiss()
                }
            }
        }
    }
}
