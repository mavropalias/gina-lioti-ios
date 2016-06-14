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
    public func imageFromUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main()) {
                (response: URLResponse?, data: Data?, error: NSError?) -> Void in
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
    var fetchedResultsController: NSFetchedResultsController<AnyObject> {
        // return if already initialized
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }

        let appDel:AppDelegate = (UIApplication.shared().delegate as! AppDelegate)
        let managedObjectContext = appDel.managedObjectContext//self.managedObjectContext!

        let entity = NSEntityDescription.entity(forEntityName: "Recipe", in: managedObjectContext)
        let sort = SortDescriptor(key: "title", ascending: true)
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
    var _fetchedResultsController: NSFetchedResultsController<AnyObject>?





// MARK: - IBOutlets
// =============================================================================

    @IBOutlet weak var collectionView: UICollectionView!





// MARK: - UIViewController
// =============================================================================

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipes";
    }

    override func viewWillAppear(_ animated: Bool) {
        cellWidth = self.view.frame.size.width
        cellHeight = self.view.frame.size.height
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        cellWidth = self.view.frame.size.height
        cellHeight = self.view.frame.size.width
        collectionView.reloadData()
    }





// MARK: - Helpers
// =============================================================================

    func showRecipe(_ recipeId: Int) {
        guard let recipes = fetchedResultsController.fetchedObjects as? [Recipe] else { return }

        for recipe in recipes {
            if recipe.id == recipeId {
                performSegue(withIdentifier: "showRecipeDetails", sender: recipe)
                break
            }
        }
    }




// MARK: - UICollectionViewDelegateFlowLayout
// =============================================================================

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight / 3)
    }





// MARK: - UICollectionViewDataSource
// =============================================================================

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let info = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RecipeCollectionViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    /* helper method to configure a `UITableViewCell`
    ask `NSFetchedResultsController` for the model */
    func configureCell(_ cell: RecipeCollectionViewCell, atIndexPath indexPath: IndexPath) {
        let recipe = self.fetchedResultsController.object(at: indexPath) as! Recipe
        cell.titleLabel.text = recipe.title
        //cell.detailTextLabel!.text = "\(recipe.photos?.count) photos"

        if let photoArray = recipe.photos?.allObjects {
            if !photoArray.isEmpty {
                let photo: RecipePhoto = photoArray[0] as! RecipePhoto

//                let photoUrl = photo.url!
//                let extensionIndex = advance(photoUrl.endIndex, -4)
//                let baseImagePath = photoUrl.substringToIndex(extensionIndex).lowercaseString
//                let image = "\(baseImagePath)-1200x630.jpg"
//
//                cell.imageView!.image = nil
//
//                let image_url = NSURL(string: image)
//                let url_request = NSURLRequest(URL: image_url!)
//                let placeholder = UIImage(named: "no_photo")
//                cell.imageView!.setImageWithURLRequest(url_request, placeholderImage: placeholder, success: { [weak cell] (request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
//                    if let cell_for_image = cell {
//                        cell_for_image.imageView!.image = image
//                        cell_for_image.setNeedsLayout()
//                    }
//                    }, failure: { [weak cell]
//                        (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
//                        if let cell_for_image = cell {
//                            cell_for_image.imageView!.image = nil
//                            cell_for_image.setNeedsLayout()
//                        }
//                    })
            }
        }
    }





// MARK: - NSFetchedResultsControllerDelegate
// =============================================================================

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let nip = newIndexPath else { return }
            collectionView.insertItems(at: [nip])
        case .update:
            guard let ip = indexPath else { return }
            if let cell = collectionView.cellForItem(at: ip) as? RecipeCollectionViewCell {
                configureCell(cell, atIndexPath: indexPath!)
                collectionView.reloadItems(at: [indexPath!])
            }
        case .move:
            guard
                let ip = indexPath,
                let nip = newIndexPath
                where ip != nip
                else { return }
            collectionView.deleteItems(at: [ip])
            collectionView.insertItems(at: [nip])
        case .delete:
            guard let ip = indexPath else { return }
            collectionView.deleteItems(at: [ip])
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
    }





// MARK: - Navigation
// =============================================================================

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier! == "showRecipeDetails") {
            guard let recipeDetailsVC = segue.destinationViewController as? RecipeDetailsVC else { return }

            if (sender!.isKind(RecipeCollectionViewCell)) {
                guard let cell = sender as? RecipeCollectionViewCell else { return }
                guard let indexPath = self.collectionView!.indexPath(for: cell) else { return }
                recipeDetailsVC.recipe = self.fetchedResultsController.object(at: indexPath) as? Recipe
            } else if (sender!.isKind(Recipe)) {
                recipeDetailsVC.recipe = sender as? Recipe
            }
        }
    }


















}
