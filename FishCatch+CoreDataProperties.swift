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
}

extension FishCatch : Identifiable {

}
