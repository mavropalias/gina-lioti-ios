//
//  RecipeDetailsVC.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 01/08/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import UIKit

class RecipeDetailsVC: UIViewController {





// MARK: - Class properties
// =============================================================================

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var recipeImageView: UIImageView!

    var recipe: Recipe? {
        didSet {

        }
    }





// MARK: - UIViewController
// =============================================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureSelfWithRecipe()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func configureSelfWithRecipe() {
        if let photoArray = recipe!.photos?.allObjects {
            if !photoArray.isEmpty {
                let photo: RecipePhoto = photoArray[0] as! RecipePhoto

                let photoUrl = photo.url!
                let extensionIndex = advance(photoUrl.endIndex, -4)
                let baseImagePath = photoUrl.substringToIndex(extensionIndex).lowercaseString
                let image = "\(baseImagePath)-1200x630.jpg"

                recipeImageView.image = nil

                let image_url = NSURL(string: image)
                let url_request = NSURLRequest(URL: image_url!)
                let placeholder = UIImage(named: "no_photo")
                recipeImageView.setImageWithURLRequest(url_request, placeholderImage: placeholder, success: { [weak recipeImageView] (request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                    if let cell_for_image = recipeImageView {
                        cell_for_image.image = image
                    }
                    }, failure: { [weak recipeImageView]
                        (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
                        if let cell_for_image = recipeImageView {
                            cell_for_image.image = nil
                        }
                    })
            }
        }
    }

}
