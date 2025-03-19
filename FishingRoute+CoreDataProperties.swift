import Foundation
import CoreData
import CoreLocation

@objc(FishingRoute)
public class FishingRoute: NSManagedObject {

}

extension FishingRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FishingRoute> {
        return NSFetchRequest<FishingRoute>(entityName: "FishingRoute")
    }

    @NSManaged public var name: String?
    @NSManaged public var spots: [CLLocationCoordinate2D]?
    
    var spotsArray: [CLLocationCoordinate2D] {
        get { spots as? [CLLocationCoordinate2D] ?? [] }
        set { spots = newValue as NSObject }
    }

}

extension FishingRoute : Identifiable {
   
}
