//
//  CoreDataManager.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 12/07/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class CoreDataManager {
    func load() -> ([Recipe]?, [Ingredient]?) {
        var recipes: [Recipe]? = nil
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let model = managedContext.persistentStoreCoordinator?.managedObjectModel
        let substitutionVariabledDictionary = ["RECIPE_ID":1]
        let fetchRequest = model?.fetchRequestFromTemplateWithName("FetchAllRecipes", substitutionVariables: [:])
        do {
            recipes = try managedContext.executeFetchRequest(fetchRequest!) as? [Recipe]
            return (recipes, nil)
        } catch {
            return (nil, nil)
        }
    }
}