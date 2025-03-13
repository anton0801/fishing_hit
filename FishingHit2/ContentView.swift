import SwiftUI
import CoreData
import MapKit
import WebKit
import PhotosUI

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
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
            SupportPage()
                .tabItem { Label("Support", systemImage: "questionmark.circle") }
                .tag(3)
//            ARFishView()
//                .tabItem { Label("AR", systemImage: "camera") }
//                .tag(3)
        }
        .accentColor(.yellow)
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
        sortDescriptors: [NSSortDescriptor(keyPath: \FishCatch.fishType, ascending: true)],
        animation: .default)
    private var catches: FetchedResults<FishCatch>
    @State private var showAddCatch = false
    @State private var selectedCatch: FishCatch? // Для хранения выбранного улова
    @State private var showCatchDetail = false // Для управления sheet
    
    var body: some View {
        NavigationView {
            List(catches) { catched in
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
                }
                .onTapGesture {
                    selectedCatch = catched
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showCatchDetail = true
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        deleteCatch(catched)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .background(Color.seaDark)
            .navigationTitle("Diary")
            .toolbar {
                Button(action: { withAnimation { showAddCatch.toggle() } }) {
                    Image(systemName: "plus")
                        .foregroundColor(.yellow)
                }
            }
            .sheet(isPresented: $showAddCatch) {
                AddCatchView()
            }
            .sheet(isPresented: $showCatchDetail) {
                if let selectedCatch = selectedCatch {
                    CatchDetailView(catched: selectedCatch)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
    
    private func deleteCatch(_ catched: FishCatch) {
        withAnimation {
            viewContext.delete(catched)
            do {
                try viewContext.save()
            } catch {
            }
        }
    }
}

struct CatchDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var catched: FishCatch
    @State private var note: String // Для редактирования заметки
    
    init(catched: FishCatch) {
        self.catched = catched
        _note = State(initialValue: catched.note ?? "") // Инициализируем заметку из объекта
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Фото на полный размер
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
            
            // Информация об улове
            Text(catched.fishType ?? "Unknown")
                .font(.title)
                .foregroundColor(.turquoise)
            Text("Weight: \(catched.weight) kg")
                .font(.body)
            Text("Length: \(catched.length) cm")
                .font(.body)
            
            // Поле для заметки
            Text("Note:")
                .font(.headline)
                .foregroundColor(.turquoise)
            TextEditor(text: $note)
                .frame(height: 100)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
                .foregroundColor(.white)
            
            // Кнопка сохранения
            Button("Save Note") {
                catched.note = note
                do {
                    try viewContext.save()
                    dismiss()
                } catch {
                    print("Failed to save note: \(error)")
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

struct AddCatchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @State private var fishType = ""
    @State private var weight = ""
    @State private var length = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var note = "" // Новое поле для заметки
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Fish Type", text: $fishType)
                TextField("Weight (kg)", text: $weight)
                TextField("Length (cm)", text: $length)
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
                    if let image = image {
                        if let imageData = image.jpegData(compressionQuality: 0.8), !imageData.isEmpty {
                            newCatch.image = imageData
                        } else {
                            print("Error: Could not convert image to valid JPEG data")
                        }
                    }
                    newCatch.note = note // Сохранение заметки
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
                    guard let item = newItem else { return }
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        guard !data.isEmpty, data.count > 0 else {
                            print("Error: Photo data is empty or invalid")
                            return
                        }
                        if let uiImage = UIImage(data: data) {
                            image = uiImage
                        } else {
                            print("Error: Could not create UIImage from data")
                        }
                    } else {
                        print("Error: Failed to load photo data")
                    }
                }
            }
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
    
    var body: some View {
        NavigationView {
            List(fishData) { fish in
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
                .onTapGesture {
                    selectedFish = fish
                    showFishDetail = true
                }
            }
            .background(Color.seaDark)
            .navigationTitle("Fish Guide")
            .sheet(isPresented: $showFishDetail) {
                if let selectedFish = selectedFish {
                    FishDetailView(fish: selectedFish)
                }
            }
        }
    }
}

struct FishDetailView: View {
    let fish: FishInfo
    
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
