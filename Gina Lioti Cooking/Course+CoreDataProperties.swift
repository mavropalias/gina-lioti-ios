//
//  Course+CoreDataProperties.swift
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

extension Course {

    @NSManaged var id: NSNumber?
    @NSManaged var recipes: NSSet?

}
