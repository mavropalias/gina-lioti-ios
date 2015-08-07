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


class RecipesVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {





// MARK: - Class properties
// =============================================================================

    var cellWidth: CGFloat = 600.0
    var cellHeight: CGFloat = 200.0
    var managedObjectContext: NSManagedObjectContext?
    var fetchedResultsController: NSFetchedResultsController {
        // return if already initialized
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }

        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let managedObjectContext = appDel.managedObjectContext//self.managedObjectContext!

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





// MARK: - IBOutlets
// =============================================================================

    @IBOutlet weak var collectionView: UICollectionView!





// MARK: - UIViewController
// =============================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gina's Recipes";
    }

    override func viewWillAppear(animated: Bool) {
        cellWidth = self.view.frame.size.width
        cellHeight = self.view.frame.size.height
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        cellWidth = self.view.frame.size.height
        cellHeight = self.view.frame.size.width
        collectionView.reloadData()
    }





// MARK: - UICollectionViewDelegateFlowLayout
// =============================================================================

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(cellWidth, cellHeight / 3)
    }





// MARK: - UICollectionViewDataSource
// =============================================================================

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let info = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! RecipeCollectionViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    /* helper method to configure a `UITableViewCell`
    ask `NSFetchedResultsController` for the model */
    func configureCell(cell: RecipeCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let recipe = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Recipe
        cell.titleLabel.text = recipe.title
        //cell.detailTextLabel!.text = "\(recipe.photos?.count) photos"

        if let photoArray = recipe.photos?.allObjects {
            if !photoArray.isEmpty {
                let photo: RecipePhoto = photoArray[0] as! RecipePhoto

                let photoUrl = photo.url!
                let extensionIndex = advance(photoUrl.endIndex, -4)
                let baseImagePath = photoUrl.substringToIndex(extensionIndex).lowercaseString
                let image = "\(baseImagePath)-1200x630.jpg"

                cell.imageView!.image = nil

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





// MARK: - NSFetchedResultsControllerDelegate
// =============================================================================

    func controllerWillChangeContent(controller: NSFetchedResultsController) {

    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            guard let nip = newIndexPath else { return }
            collectionView.insertItemsAtIndexPaths([nip])
        case .Update:
            guard let ip = indexPath else { return }
            if let cell = collectionView.cellForItemAtIndexPath(ip) as? RecipeCollectionViewCell {
                configureCell(cell, atIndexPath: indexPath!)
                collectionView.reloadItemsAtIndexPaths([indexPath!])
            }
        case .Move:
            guard
                let ip = indexPath,
                let nip = newIndexPath
                where ip != nip
                else { return }
            collectionView.deleteItemsAtIndexPaths([ip])
            collectionView.insertItemsAtIndexPaths([nip])
        case .Delete:
            guard let ip = indexPath else { return }
            collectionView.deleteItemsAtIndexPaths([ip])
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
    }





// MARK: - NSFetchedResultsControllerDelegate
// =============================================================================
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier! == "showRecipeDetails") {
            guard let recipeDetailsVC = segue.destinationViewController as? RecipeDetailsVC else { return }
            guard let cell = sender as? RecipeCollectionViewCell else { return }
            guard let indexPath = self.collectionView!.indexPathForCell(cell) else { return }
            let recipe = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Recipe
            recipeDetailsVC.recipe = recipe
        }
    }


















}