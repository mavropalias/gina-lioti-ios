//
//  RecipesVC.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 26/06/2015.
//  Copyright © 2015 gl. All rights reserved.
//





import UIKit





class RecipesVC: UIViewController, UITableViewDataSource {





// MARK: Class properties
// =============================================================================

    let appDataManager = AppDataManager()
    var recipes: [Recipe] = []





// MARK: IBOutlets
// =============================================================================

    @IBOutlet weak var tableView: UITableView!





// MARK: UIViewController
// =============================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes";
        if let dataRecipes = appDataManager.recipes {
            recipes = dataRecipes
            title = String(dataRecipes.count) + " recipes"
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);

        if let dataRecipes = appDataManager.recipes {
            recipes = dataRecipes
            title = String(dataRecipes.count) + " recipes"
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("recipeCell") as UITableViewCell?
        let recipe = recipes[indexPath.row]
        cell?.textLabel!.text = recipe.title
        cell?.detailTextLabel!.text = recipe.servingsType

        return cell!
    }





}