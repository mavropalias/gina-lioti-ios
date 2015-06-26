//
//  Recipe+CoreDataProperties.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 26/06/2015.
//  Copyright © 2015 gl. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Recipe {

    @NSManaged var id: NSNumber?
    @NSManaged var servingsCount: NSNumber?
    @NSManaged var descriptionText: String?
    @NSManaged var datePublished: NSDate?
    @NSManaged var title: String?
    @NSManaged var servingsType: String?
    @NSManaged var prepMinutes: NSNumber?
    @NSManaged var cookMinutes: NSNumber?
    @NSManaged var waitMinutes: NSNumber?
    @NSManaged var ingredients: NSSet?
    @NSManaged var courses: NSSet?

}
