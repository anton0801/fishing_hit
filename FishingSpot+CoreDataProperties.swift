import Foundation
import CoreData
import CoreLocation

extension FishingSpot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FishingSpot> {
        return NSFetchRequest<FishingSpot>(entityName: "FishingSpot")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var fishType: String? // Убедитесь, что это есть
    @NSManaged public var depth: Double
    @NSManaged public var gear: String?
    @NSManaged public var iconName: String?


}

extension FishingSpot : Identifiable {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
