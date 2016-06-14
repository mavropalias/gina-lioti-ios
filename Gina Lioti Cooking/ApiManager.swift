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
    let app = (UIApplication.shared().delegate as! AppDelegate)
    lazy var managedObjectContext = {
        return (UIApplication.shared().delegate as! AppDelegate).managedObjectContext
    }()
    let printPrefix: String = "–––––– "





// MARK: - Class methods
// =============================================================================

    // fetch
    func fetch() {
        let fetchUrl = URL(string: url)!
        let task = URLSession.shared().dataTask(with: fetchUrl) {(data, response, error) in
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
    private func parseApiData(_ data: Data) {
        guard let recipesJsonArray = getRecipesJsonArrayFromApiData(data) else { return }

        // Parse JSON recipe array
        var recipes = [Recipe]()

        guard let entity = NSEntityDescription.entity(forEntityName: "Recipe", in: managedObjectContext) else { return }

        for recipeJson in recipesJsonArray {
            guard let recipeId = recipeJson.value(forKey: "id") as? NSNumber else { return }
            var recipe = NSManagedObject(entity: entity, insertInto: nil) as! Recipe
            var needToSaveRecipe = true

            if let localRecipe = getExistingRecipeById(recipeId) {
                recipe = localRecipe
                needToSaveRecipe = false
            } else {
                recipe.id = recipeId
            }

            if let title = recipeJson.value(forKey: "title") as? String {
                recipe.title = decodeHtmlEncodedString(title)
            } else {
                recipe.title = ""
            }

            recipe.datePublished = dateFromString(recipeJson.value(forKey: "date") as! String)
            recipe.dateModified = dateFromString(recipeJson.value(forKey: "modified") as! String)

            if let photos = recipeJson.value(forKey: "attachments") as? Array<NSDictionary> {
                //recipe.photos = photosetFromJson(photos, forRecipe: recipe)
                insertRecipePhotosToCoreDataFromJson(photos, forRecipe: recipe)
            }

            recipe.slug = recipeJson.value(forKey: "slug") as? String
            recipe.descriptionA = recipeJson.value(forKey: "description") as? String
            recipe.descriptionB = decodeHtmlEncodedString((recipeJson.value(forKey: "content") as? String)!)
            recipe.minutesCook = 0
            recipe.minutesPassive = 0
            recipe.minutesPrep = 0
            recipe.minutesTotal = 0
            recipe.servingsCount = 0
            recipe.servingsType = recipeJson.value(forKey: "servings") as? String

            recipes.append(recipe)

            // Save recipe
            if needToSaveRecipe {
                print("+++ Saving new recipe \(recipe.title!)")
                managedObjectContext.insert(recipe)
            } else {
                print(">>> Updating recipe \(recipe.title!)")
                managedObjectContext.refresh(recipe, mergeChanges: true)
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

    private func getRecipesJsonArrayFromApiData(_ data: Data) -> Array<NSDictionary>? {
        do {
            let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

            guard let status = jsonDictionary.value(forKey: "status") as? String else { return nil }
            if status == "ok" {
                return jsonDictionary.value(forKey: "posts") as? Array<NSDictionary>
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    private func getExistingRecipeById(_ recipeId: NSNumber) -> Recipe? {
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        let predicate = Predicate(format: "%K == %@", "id", recipeId);
        fetchRequest.predicate = predicate

        do {
            let localRecipe:Array<Recipe> = try managedObjectContext.fetch(fetchRequest) as! [Recipe]
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

    private func getExistingPhotoByUrl(_ photoUrl: String) -> RecipePhoto? {
        let fetchRequest = NSFetchRequest(entityName: "RecipePhoto")
        let predicate = Predicate(format: "%K == %@", "url", photoUrl);
        fetchRequest.predicate = predicate

        do {
            let localPhoto:Array<RecipePhoto> = try managedObjectContext.fetch(fetchRequest) as! [RecipePhoto]
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

    private func insertRecipePhotosToCoreDataFromJson(_ photosJsonArray: Array<NSDictionary>, forRecipe recipe: Recipe) {
        for photoJson in photosJsonArray {
            guard let entity = NSEntityDescription.entity(forEntityName: "RecipePhoto", in: managedObjectContext) else { break }
            if var recipePhoto = NSManagedObject(entity: entity, insertInto: nil) as? RecipePhoto {
                guard let photoUrl = photoJson.value(forKey: "url") as? String else { break }
                print("Parsing photo \(photoUrl)")
                var needToSavePhoto = true
                if let localPhoto = getExistingPhotoByUrl(photoUrl) {
                    print("– Photo exists locally")
                    recipePhoto = localPhoto
                    needToSavePhoto = false
                } else {
                    print("– Photo is new")
                    recipePhoto.url = photoJson.value(forKey: "url") as? String
                    recipePhoto.recipe = recipe
                }

                recipePhoto.descrip = photoJson.value(forKey: "description") as? String
                recipePhoto.caption = photoJson.value(forKey: "caption") as? String
                recipePhoto.title = photoJson.value(forKey: "title") as? String

                if needToSavePhoto {
                    print("– Inserting photo object")
                    managedObjectContext.insert(recipePhoto)
                } else {
                    print("– Refreshing photo object")
                    managedObjectContext.refresh(recipePhoto, mergeChanges: true)
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

    private func decodeHtmlEncodedString(_ html: String) -> String {
        let encodedData = html.data(using: String.Encoding.utf8)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8
        ]

        let attributedString: AttributedString

        do {
            attributedString = try AttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            return ""
        }
        return attributedString.string
    }

    private func dateFromString (_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            return date;
        } else {
            return nil
        }
    }
}
