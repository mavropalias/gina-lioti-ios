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

    var recipes = [NSManagedObject]()





// MARK: IBOutlets
// =============================================================================

    @IBOutlet weak var tableView: UITableView!





// MARK: UIViewController
// =============================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes";
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Recipe")

        do {
            recipes = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        } catch {

        }


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
        let recipe = recipes[indexPath.row] as? Recipe
        cell?.textLabel!.text = recipe?.title

        return cell!
    }





}

