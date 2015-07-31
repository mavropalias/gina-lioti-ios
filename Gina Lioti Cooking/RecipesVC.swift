//
//  RecipesVC.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 26/06/2015.
//  Copyright © 2015 gl. All rights reserved.
//





import UIKit
import CoreData


extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let imageData = data {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}


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
        cell.detailTextLabel!.text = "\(recipe.photos?.count) photos"

        if let photoArray = recipe.photos?.allObjects {
            if !photoArray.isEmpty {
                let photo: RecipePhoto = photoArray[0] as! RecipePhoto

                let photoUrl = photo.url!
                let extensionIndex = advance(photoUrl.endIndex, -4)
                let baseImagePath = photoUrl.substringToIndex(extensionIndex)
                let image = "\(baseImagePath)-1120x630.jpg"

                cell.imageView!.image = nil

                if (image != "") {
                    let image_url = NSURL(string: image)
                    let url_request = NSURLRequest(URL: image_url!)
                    let placeholder = UIImage(named: "no_photo")
                    cell.imageView!.setImageWithURLRequest(url_request, placeholderImage: placeholder, success: { [weak cell] (request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                        if let cell_for_image = cell {
                            cell_for_image.imageView!.image = image
                            cell_for_image.setNeedsLayout()
                        }
                        }, failure: { [weak cell]
                            (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
                            if let cell_for_image = cell {
                                cell_for_image.imageView!.image = nil
                                cell_for_image.setNeedsLayout()
                            }
                        })
                }
            }
        }
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