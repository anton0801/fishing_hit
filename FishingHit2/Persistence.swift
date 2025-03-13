import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FishingHit2")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Ошибка загрузки хранилища: \(error), \(error.userInfo)")
            }
        }
    }
    
    private func cleanInvalidData() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<FishCatch> = FishCatch.fetchRequest()
        
        do {
            let catches = try context.fetch(fetchRequest)
            for catched in catches {
                if let imageData = catched.image, imageData.count <= 0 {
                    print("Найден улов catched некорректным изображением: \(catched.fishType ?? "unknown")")
                    context.delete(catched)
                }
            }
            try context.save()
        } catch {
            print("Ошибка при очистке данных: \(error)")
        }
    }
}
