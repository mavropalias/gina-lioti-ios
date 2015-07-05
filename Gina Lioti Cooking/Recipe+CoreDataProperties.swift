
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
    @NSManaged var descriptionA: String?
    @NSManaged var datePublished: NSDate?
    @NSManaged var title: String?
    @NSManaged var servingsType: String?
    @NSManaged var minutesPrep: NSNumber?
    @NSManaged var minutesCook: NSNumber?
    @NSManaged var minutesPassive: NSNumber?
    @NSManaged var descriptionB: String?
    @NSManaged var minutesTotal: NSNumber?
    @NSManaged var ingredients: NSSet?
    @NSManaged var courses: NSSet?
    @NSManaged var relatedRecipes: NSSet?
    @NSManaged var photos: NSSet?
    @NSManaged var instructions: NSSet?

}
