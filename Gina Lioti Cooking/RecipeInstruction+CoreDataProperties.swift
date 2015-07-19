//
//  RecipeInstruction+CoreDataProperties.swift
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

extension RecipeInstruction {

    @NSManaged var group: String?
    @NSManaged var imageUrl: String?
    @NSManaged var instruction: String?
    @NSManaged var recipe: Recipe?

}
