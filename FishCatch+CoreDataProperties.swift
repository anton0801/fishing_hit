import Foundation
import CoreData


extension FishCatch {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FishCatch> {
        return NSFetchRequest<FishCatch>(entityName: "FishCatch")
    }

    @NSManaged public var fishType: String?
    @NSManaged public var weight: Double
    @NSManaged public var length: Double
    @NSManaged public var image: Data?
    @NSManaged public var note: String?
    @NSManaged public var date: Date? // Новый атрибут для даты
    @NSManaged public var audioURL: String? // Новый атрибут для аудио
    @NSManaged public var videoURL: String? // Новый атрибут для видео
}

extension FishCatch : Identifiable {

}
