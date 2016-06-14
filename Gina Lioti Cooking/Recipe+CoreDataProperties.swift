//
//  Recipe+CoreDataProperties.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 19/07/2015.
//  Copyright © 2015 gl. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Recipe {

    @NSManaged var dateModified: Date?
    @NSManaged var datePublished: Date?
    @NSManaged var descriptionA: String?
    @NSManaged var descriptionB: String?
    @NSManaged var id: NSNumber?
    @NSManaged var minutesCook: NSNumber?
    @NSManaged var minutesPassive: NSNumber?
    @NSManaged var minutesPrep: NSNumber?
    @NSManaged var minutesTotal: NSNumber?
    @NSManaged var servingsCount: NSNumber?
    @NSManaged var servingsType: String?
    @NSManaged var slug: String?
    @NSManaged var title: String?
    @NSManaged var courses: NSSet?
    @NSManaged var ingredients: NSSet?
    @NSManaged var instructions: NSSet?
    @NSManaged var photos: NSSet?
    @NSManaged var relatedRecipes: NSSet?

}
