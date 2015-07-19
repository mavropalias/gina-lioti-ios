//
//  RecipesVC.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 26/06/2015.
//  Copyright © 2015 gl. All rights reserved.
//





import UIKit
import CoreData





class RecipesVC: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {





// MARK: Class properties
// =============================================================================

    var managedObjectContext: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController {
        // return if already initialized
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        let managedObjectContext = self.managedObjectContext!

        let entity = NSEntityDescription.entityForName("Recipe", inManagedObjectContext: managedObjectContext)
        let sort = NSSortDescriptor(key: "title", ascending: true)
        let req = NSFetchRequest()
        req.entity = entity
        req.sortDescriptors = [sort]

        /* NSFetchedResultsController initialization
        a `nil` `sectionNameKeyPath` generates a single section */
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        self._fetchedResultsController = aFetchedResultsController

        // perform initial model fetch
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort();
        }

        return self._fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController?





// MARK: IBOutlets
// =============================================================================

    @IBOutlet weak var tableView: UITableView!





// MARK: UIViewController
// =============================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes";
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
        let info = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recipeCell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    /* helper method to configure a `UITableViewCell`
    ask `NSFetchedResultsController` for the model */
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let recipe = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Recipe
        cell.textLabel!.text = recipe.title
        cell.detailTextLabel!.text = recipe.servingsType
    }





// MARK: NSFetchedResultsControllerDelegate
// =============================================================================

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            guard let nip = newIndexPath else { return }
            tableView.insertRowsAtIndexPaths([nip], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Update:
            guard let ip = indexPath else { return }
            if let cell = tableView.cellForRowAtIndexPath(ip) {
                configureCell(cell, atIndexPath: indexPath!)
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case .Move:
            guard
                let ip = indexPath,
                let nip = newIndexPath
                where ip != nip
                else { return }
            tableView.deleteRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.insertRowsAtIndexPaths([nip], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            guard let ip = indexPath else { return }
            tableView.deleteRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }



















}