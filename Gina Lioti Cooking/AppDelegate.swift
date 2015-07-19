//
//  AppDelegate.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 26/06/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?




    // MARK: - AppDelegate
    // =========================================================================

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Set managedObjectContext in top view
        let nav = self.window!.rootViewController as! UINavigationController
        let master = nav.topViewController as! RecipesVC
        master.managedObjectContext = self.managedObjectContext

        // Start appManager
        let appManager = AppDataManager()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }





    // MARK: - Core Data stack
    // =========================================================================

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "gl.Gina_Lioti_Cooking" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Gina_Lioti_Cooking", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.undoManager = nil
        return managedObjectContext
    }()





    // MARK: - Core Data Saving support
    // =========================================================================

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }





    // MARK: - Helpers
    // =========================================================================

    func loadJson() {
//        let jsonURL = NSBundle.mainBundle().URLForResource("RecipeData", withExtension: "json")!
//        let jsonData = NSData(contentsOfURL: jsonURL)
//        var jsonDictionary = [:]
//
//        do {
//            jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
//        } catch {
//
//        }
//
//        let recipesArray = jsonDictionary.valueForKey("recipes") as! Array<NSDictionary>
//        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//
//        for recipeJson in recipesArray {
//            let entity = NSEntityDescription.entityForName("Recipe", inManagedObjectContext: managedObjectContext)
//            var recipe = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: nil) as! Recipe
//
//            // Search for matching local recipe
//            let fetchRequest = NSFetchRequest(entityName: "Recipe")
//            let attributeValue = recipeJson.valueForKey("id") as? NSNumber;
//            let predicate = NSPredicate(format: "%K == %@", "id", attributeValue!);
//            fetchRequest.predicate = predicate
//
//            var needToSaveRecipe = true
//            do {
//                let localRecipe:Array<Recipe> = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Recipe]
//                if (localRecipe.count > 0) {
//                    recipe = localRecipe[0]
//                    needToSaveRecipe = false
//                }
//            } catch {
//                print("### ERROR 1")
//            }
//
//            // recipe date
//            let dateString = recipeJson.valueForKey("date") as? String
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
//            if let date = dateFormatter.dateFromString(dateString!) {
//                recipe.datePublished = date
//            }
//
//            // recipe photos
//            var photos:NSSet = NSSet()
//            let photosJsonArray = recipeJson.valueForKey("photos") as! Array<NSDictionary>
//            for photoJson in photosJsonArray {
//                let entityDescription = NSEntityDescription.entityForName("RecipePhoto",
//                    inManagedObjectContext: managedObjectContext)
//                let recipePhoto = RecipePhoto(entity: entityDescription!,
//                    insertIntoManagedObjectContext: nil)
//
//                recipePhoto.url = photoJson.valueForKey("url") as? String
//                photos.setByAddingObject(recipePhoto)
//            }
//
//            recipe.id = recipeJson.valueForKey("id") as? NSNumber
//            recipe.title = recipeJson.valueForKey("title") as? String
//            recipe.slug = recipeJson.valueForKey("slug") as? String
//            recipe.descriptionA = recipeJson.valueForKey("description") as? String
//            recipe.descriptionB = recipeJson.valueForKey("description2") as? String
//            recipe.minutesCook = 0
//            recipe.minutesPassive = 0
//            recipe.minutesPrep = 0
//            recipe.minutesTotal = 0
//            recipe.servingsCount = 0
//            recipe.servingsType = recipeJson.valueForKey("servings") as? String
//            recipe.photos = photos
//
////            print(recipe.title)
//
//            // Save recipe
//            if needToSaveRecipe {
//                print("Saving new recipe \(recipe.title)")
//                managedObjectContext.insertObject(recipe)
//            }
//
//            do {
//                try managedObjectContext.save()
//            } catch {
//                print("### ERROR 2")
//            }
//        }

    }
}

