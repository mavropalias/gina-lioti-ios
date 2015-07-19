//
//  API.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 12/07/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ApiManager {
    let url: String
    let printPrefix = "–––––– "

    init() {
        url = "http://ginalioti.com/api/get_posts"
    }

    func fetch() -> ([Recipe]?, [Ingredient]?) {
        let fetchUrl = NSURL(string: url)!
        var recipes = [Recipe]()
        var ingredients = [Ingredient]()

        let task = NSURLSession.sharedSession().dataTaskWithURL(fetchUrl) {(data, response, error) in
            (recipes, ingredients) = self.parseApiData(data!)
        }
        
        task?.resume()

        return (recipes, ingredients)
    }

    func parseApiData(data: NSData) -> ([Recipe], [Ingredient]) {
        var recipesArray = Array<NSDictionary>()
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        do {
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary

            // TODO: use guard?
            if let status = jsonDictionary.valueForKey("status")! as? String {
                if status == "ok" {
                    recipesArray = jsonDictionary.valueForKey("posts")! as! Array<NSDictionary>
                } else {
                    return ([], [])
                }
            }
        } catch {
            // TODO: add catch conditions
        }

        // Parse JSON recipe array
        var recipes = [Recipe]()
        for recipeJson in recipesArray {
            // TODO: remove retracted recipes?
            let entity = NSEntityDescription.entityForName("Recipe", inManagedObjectContext: managedObjectContext)
            var recipe = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: nil) as! Recipe

            // Search for matching local recipe
            let fetchRequest = NSFetchRequest(entityName: "Recipe")
            let attributeValue = recipeJson.valueForKey("id") as? NSNumber;
            let predicate = NSPredicate(format: "%K == %@", "id", attributeValue!);
            fetchRequest.predicate = predicate

            var needToSaveRecipe = true
            do {
                let localRecipe:Array<Recipe> = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Recipe]
                if (localRecipe.count > 0) {
                    recipe = localRecipe[0]
                    needToSaveRecipe = false
                }
            } catch {
                print("### ERROR 1")
            }

            // Recipe dates
            // -----------------------------------------------------------------
            recipe.datePublished = dateFromString(recipeJson.valueForKey("date") as! String)
            recipe.dateModified = dateFromString(recipeJson.valueForKey("modified") as! String)

            // recipe photos
//            var photos:NSSet = NSSet()
//            let photosJsonArray = recipeJson.valueForKey("photos") as! Array<NSDictionary>
//            for photoJson in photosJsonArray {
//                var recipePhoto = RecipePhoto()
//                recipePhoto.url = photoJson.valueForKey("url") as? String
//                photos.setByAddingObject(recipePhoto)
//            }

            if let title = recipeJson.valueForKey("title") as? String {
                recipe.title = decodeHtmlEncodedString(title)
            }
            recipe.id = recipeJson.valueForKey("id") as? NSNumber
            recipe.slug = recipeJson.valueForKey("slug") as? String
            recipe.descriptionA = recipeJson.valueForKey("description") as? String
            recipe.descriptionB = recipeJson.valueForKey("description2") as? String
            recipe.minutesCook = 0
            recipe.minutesPassive = 0
            recipe.minutesPrep = 0
            recipe.minutesTotal = 0
            recipe.servingsCount = 0
            recipe.servingsType = recipeJson.valueForKey("servings") as? String
//            recipe.photos = photos

            recipes.append(recipe)

            // Save recipe
            if needToSaveRecipe {
                print("+++ Saving new recipe \(recipe.title)")
                managedObjectContext.insertObject(recipe)
            } else {
                print(">>> Updating recipe \(recipe.title)")
                managedObjectContext.refreshObject(recipe, mergeChanges: true)
            }

            do {
                try managedObjectContext.save()
            } catch {
                print("### ERROR 2")
            }
        }

        print (printPrefix + "Finished importing recipes from API")
        return (recipes, [])
    }

    func decodeHtmlEncodedString(html: String) -> String {
        let encodedData = html.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]

        let attributedString: NSAttributedString

        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            return ""
        }
        return attributedString.string
    }

    func dateFromString (dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        if let date = dateFormatter.dateFromString(dateString) {
            return date;
        } else {
            return nil
        }
    }
}