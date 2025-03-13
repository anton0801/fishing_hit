import Foundation
import CoreData


extension FishingSpot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FishingSpot> {
        return NSFetchRequest<FishingSpot>(entityName: "FishingSpot")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var fishType: String? // Убедитесь, что это есть
    @NSManaged public var depth: Double
    @NSManaged public var gear: String?


}

extension FishingSpot : Identifiable {

}
