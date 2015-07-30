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





// MARK: - Class properties
// =============================================================================

    let url = "http://ginalioti.com/api/get_posts"
    let app = (UIApplication.sharedApplication().delegate as! AppDelegate)
    lazy var managedObjectContext = {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }()
    let printPrefix: String = "–––––– "





// MARK: - Class methods
// =============================================================================

    // fetch
    func fetch() {
        let fetchUrl = NSURL(string: url)!
        let task = NSURLSession.sharedSession().dataTaskWithURL(fetchUrl) {(data, response, error) in
            if let gotData = data {
                self.parseApiData(gotData)
            }
        }
        task.resume()

        app.backgroundThread(
            background: {

            },
            completion: {}
        );
    }





// MARK: - Private class methods
// =============================================================================

    // TODO: remove retracted recipes?
    private func parseApiData(data: NSData) {
        guard let recipesJsonArray = getRecipesJsonArrayFromApiData(data) else { return }

        // Parse JSON recipe array
        var recipes = [Recipe]()

        guard let entity = NSEntityDescription.entityForName("Recipe", inManagedObjectContext: managedObjectContext) else { return }

        for recipeJson in recipesJsonArray {
            guard let recipeId = recipeJson.valueForKey("id") as? NSNumber else { return }
            var recipe = NSManagedObject(entity: entity, insertIntoManagedObjectContext: nil) as! Recipe
            var needToSaveRecipe = true

            if let localRecipe = getExistingRecipeById(recipeId) {
                recipe = localRecipe
                needToSaveRecipe = false
            } else {
                recipe.id = recipeId
            }

            if let title = recipeJson.valueForKey("title") as? String {
                recipe.title = decodeHtmlEncodedString(title)
            } else {
                recipe.title = ""
            }

            recipe.datePublished = dateFromString(recipeJson.valueForKey("date") as! String)
            recipe.dateModified = dateFromString(recipeJson.valueForKey("modified") as! String)

            if let photos = recipeJson.valueForKey("attachments") as? Array<NSDictionary> {
                //recipe.photos = photosetFromJson(photos, forRecipe: recipe)
                insertRecipePhotosToCoreDataFromJson(photos, forRecipe: recipe)
            }

            recipe.slug = recipeJson.valueForKey("slug") as? String
            recipe.descriptionA = recipeJson.valueForKey("description") as? String
            recipe.descriptionB = decodeHtmlEncodedString((recipeJson.valueForKey("content") as? String)!)
            recipe.minutesCook = 0
            recipe.minutesPassive = 0
            recipe.minutesPrep = 0
            recipe.minutesTotal = 0
            recipe.servingsCount = 0
            recipe.servingsType = recipeJson.valueForKey("servings") as? String

            recipes.append(recipe)

            // Save recipe
            if needToSaveRecipe {
                print("+++ Saving new recipe \(recipe.title!)")
                managedObjectContext.insertObject(recipe)
            } else {
                print(">>> Updating recipe \(recipe.title!)")
                managedObjectContext.refreshObject(recipe, mergeChanges: true)
            }

            do {
                try managedObjectContext.save()
                //TODO: This causes continuall re-renderings on RecipesVC. Consider saving only when the recipe has actually changed.
            } catch {
                print("### ERROR 2")
            }
        }

        print (printPrefix + "Finished importing recipes from API")
    }

    private func getRecipesJsonArrayFromApiData(data: NSData) -> Array<NSDictionary>? {
        do {
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary

            guard let status = jsonDictionary.valueForKey("status") as? String else { return nil }
            if status == "ok" {
                return jsonDictionary.valueForKey("posts") as? Array<NSDictionary>
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    private func getExistingRecipeById(recipeId: NSNumber) -> Recipe? {
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        let predicate = NSPredicate(format: "%K == %@", "id", recipeId);
        fetchRequest.predicate = predicate

        do {
            let localRecipe:Array<Recipe> = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Recipe]
            if (localRecipe.count > 0) {
                return localRecipe[0]
            } else {
                return nil
            }
        } catch {
            print("### ERROR 1")
            return nil
        }
    }

    private func getExistingPhotoByUrl(photoUrl: String) -> RecipePhoto? {
        let fetchRequest = NSFetchRequest(entityName: "RecipePhoto")
        let predicate = NSPredicate(format: "%K == %@", "url", photoUrl);
        fetchRequest.predicate = predicate

        do {
            let localPhoto:Array<RecipePhoto> = try managedObjectContext.executeFetchRequest(fetchRequest) as! [RecipePhoto]
            if (localPhoto.count > 0) {
                return localPhoto[0] as RecipePhoto
            } else {
                return nil
            }
        } catch {
            print("### ERROR 1")
            return nil
        }
    }

    private func insertRecipePhotosToCoreDataFromJson(photosJsonArray: Array<NSDictionary>, forRecipe recipe: Recipe) {
        for photoJson in photosJsonArray {
            guard let entity = NSEntityDescription.entityForName("RecipePhoto", inManagedObjectContext: managedObjectContext) else { break }
            if var recipePhoto = NSManagedObject(entity: entity, insertIntoManagedObjectContext: nil) as? RecipePhoto {
                guard let photoUrl = photoJson.valueForKey("url") as? String else { break }
                print("Parsing photo \(photoUrl)")
                var needToSavePhoto = true
                if let localPhoto = getExistingPhotoByUrl(photoUrl) {
                    print("– Photo exists locally")
                    recipePhoto = localPhoto
                    needToSavePhoto = false
                } else {
                    print("– Photo is new")
                    recipePhoto.url = photoJson.valueForKey("url") as? String
                    recipePhoto.recipe = recipe
                }

                recipePhoto.descrip = photoJson.valueForKey("description") as? String
                recipePhoto.caption = photoJson.valueForKey("caption") as? String
                recipePhoto.title = photoJson.valueForKey("title") as? String

                if needToSavePhoto {
                    print("– Inserting photo object")
                    managedObjectContext.insertObject(recipePhoto)
                } else {
                    print("– Refreshing photo object")
                    managedObjectContext.refreshObject(recipePhoto, mergeChanges: true)
                }

                do {
                    print("– Saving photo context")
                    try managedObjectContext.save()
                } catch {
                    print("### ERROR 3")
                }
            }
        }
    }

    private func decodeHtmlEncodedString(html: String) -> String {
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

    private func dateFromString (dateString: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        if let date = dateFormatter.dateFromString(dateString) {
            return date;
        } else {
            return nil
        }
    }
}