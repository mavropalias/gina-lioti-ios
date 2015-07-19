//
//  RecipePhoto+CoreDataProperties.swift
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

extension RecipePhoto {

    @NSManaged var caption: String?
    @NSManaged var descrip: String?
    @NSManaged var photo: NSData?
    @NSManaged var title: String?
    @NSManaged var url: String?
    @NSManaged var recipe: Recipe?

}
