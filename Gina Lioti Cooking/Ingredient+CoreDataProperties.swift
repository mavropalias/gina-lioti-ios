//
//  Ingredient+CoreDataProperties.swift
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

extension Ingredient {

    @NSManaged var id: NSNumber?
    @NSManaged var title: String?
    @NSManaged var descrip: String?
    @NSManaged var recipeCount: NSNumber?
    @NSManaged var slug: String?
    @NSManaged var recipeIngredients: NSSet?

}
