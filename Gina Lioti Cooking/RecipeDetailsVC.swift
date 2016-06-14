//
//  RecipeDetailsVC.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 01/08/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

class RecipeDetailsVC: UIViewController {





// MARK: - Class properties
// =============================================================================

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeDescription: UITextView!

    var recipe: Recipe? {
        didSet {

        }
    }





// MARK: - UIViewController
// =============================================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        recipeDescription.isScrollEnabled = false
        recipeDescription.textContainer.lineFragmentPadding = 0 // remove left+right padding

        // handoff
        let activity = NSUserActivity(activityType: "com.ginalioti.handoff-recipe")
        activity.title = recipe?.title
        activity.userInfo = ["title": "", "content": ""]
        userActivity = activity
        userActivity?.becomeCurrent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSelfWithRecipe()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let fixedWidth = recipeDescription.frame.size.width
        let newSize = recipeDescription.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = recipeDescription.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        recipeDescription.frame = newFrame;
        
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func configureSelfWithRecipe() {
        title = recipe?.title
        recipeDescription.text = recipe?.descriptionB!

//        if let photoArray = recipe!.photos?.allObjects {
//            if !photoArray.isEmpty {
//                let photo: RecipePhoto = photoArray[0] as! RecipePhoto
//
//                let photoUrl = photo.url!
//                let extensionIndex = advance(photoUrl.endIndex, -4)
//                let baseImagePath = photoUrl.substringToIndex(extensionIndex).lowercaseString
//                let image = "\(baseImagePath)-1200x630.jpg"
//
//                recipeImageView.image = nil
//
//                let image_url = NSURL(string: image)
//                let url_request = NSURLRequest(URL: image_url!)
//                let placeholder = UIImage(named: "no_photo")
//                recipeImageView.setImageWithURLRequest(url_request, placeholderImage: placeholder, success: { [weak recipeImageView] (request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
//                    if let cell_for_image = recipeImageView {
//                        cell_for_image.image = image
//                        self.indexRecipe(image)
//                    }
//                    }, failure: { [weak recipeImageView]
//                        (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
//                        if let cell_for_image = recipeImageView {
//                            cell_for_image.image = nil
//                        }
//                    })
//            }
//        }
    }

    func indexRecipe(_ image: UIImage) {
        // Index recipe in core spotlight
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = self.recipe!.title
        attributeSet.contentDescription = self.recipe!.descriptionA
        attributeSet.keywords = ["gina", "lioti", "greek", "recipe"]
        attributeSet.thumbnailData = NSData(data: UIImagePNGRepresentation(image)!) as Data

        let item = CSSearchableItem(uniqueIdentifier: "\(self.recipe?.id)", domainIdentifier: "com.ginalioti", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { (error: NSError?) -> Void in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }

}
