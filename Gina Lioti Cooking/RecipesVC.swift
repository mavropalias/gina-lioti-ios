//
//  RecipesVC.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 26/06/2015.
//  Copyright © 2015 gl. All rights reserved.
//





import UIKit
import CoreData





class RecipesVC: UIViewController, UITableViewDataSource {





// MARK: Class properties
// =============================================================================

    var recipes = [Recipe]()





// MARK: IBOutlets
// =============================================================================

    @IBOutlet weak var tableView: UITableView!





// MARK: UIViewController
// =============================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes";
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // Load recipes into memory
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        do {
            recipes = try managedContext.executeFetchRequest(fetchRequest) as! [Recipe]
        } catch {

        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // Update recipes from server
        self.loadJson()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }





// MARK: UITableViewDataSource
// =============================================================================

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell?
        let recipe = recipes[indexPath.row]
        cell?.textLabel!.text = recipe.title

        return cell!
    }





// MARK: Helpers
// =============================================================================

    func loadJson() {
        let jsonURL = NSBundle.mainBundle().URLForResource("RecipeData", withExtension: "json")!
        let jsonData = NSData(contentsOfURL: jsonURL)
        var jsonDictionary = [:]

        do {
            jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        } catch {

        }

        let recipesArray = jsonDictionary.valueForKey("recipes") as! Array<NSDictionary>
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        for recipeJson in recipesArray {
            let entity = NSEntityDescription.entityForName("Recipe", inManagedObjectContext: managedObjectContext)
            var recipe = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: nil) as! Recipe

            // Check if recipe exists locally
            var needToSaveRecipe = true
            for localRecipe in recipes {
                print(localRecipe.title)
                if (localRecipe.id == (recipeJson.valueForKey("id") as? NSNumber)) {
                    needToSaveRecipe = false
                    recipe = localRecipe
                }
            }

            // recipe date
            let dateString = recipeJson.valueForKey("date") as? String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
            if let date = dateFormatter.dateFromString(dateString!) {
                recipe.datePublished = date
            }

            recipe.id = recipeJson.valueForKey("id") as? NSNumber
            recipe.title = recipeJson.valueForKey("title") as? String
            recipe.descriptionA = recipeJson.valueForKey("description") as? String
            recipe.descriptionB = recipeJson.valueForKey("description2") as? String
            recipe.minutesCook = 0
            recipe.minutesPassive = 0
            recipe.minutesPrep = 0
            recipe.minutesTotal = 0
            recipe.servingsCount = 0
            recipe.servingsType = recipeJson.valueForKey("servings") as? String

            print(recipe.title)

            // Save recipe
            if needToSaveRecipe {
                managedObjectContext.insertObject(recipe)
            }

            do {
                try managedObjectContext.save()
            } catch {
                print("### ERROR")
            }
        }

    }
}