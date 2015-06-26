//
//  RecipeIngredients+CoreDataProperties.swift
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

extension RecipeIngredients {

    @NSManaged var notes: String?
    @NSManaged var quantity: String?
    @NSManaged var group: String?
    @NSManaged var unit: String?
    @NSManaged var quantityNormalized: NSNumber?
    @NSManaged var ingredient: Ingredient?
    @NSManaged var recipe: Recipe?

}
