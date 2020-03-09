//
//  CoreDataPhotos.swift
//  MyFinal
//
//  Created by Brittany Mason on 3/2/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

@objc(Photos)
public class Photos: NSManagedObject {
    
    static let name = "Photos"
    
    convenience init(title: String, imageUrl: String, cityName: Person, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: Photos.name, in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.image = nil
            self.urlImage = imageUrl
            self.cityName = cityName
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var title: String?
    @NSManaged public var urlImage: String?
    @NSManaged public var cityName: Person?

}
