//
//  API.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 12/07/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import Foundation

class ApiManager {
    let url: String

    init() {
        url = "http://ginalioti.com/api/get_posts"
    }

    func fetch() -> ([Recipe]?, [Ingredient]?) {
        let fetchUrl = NSURL(string: url)!
        var recipes = [Recipe]()
        var ingredients = [Ingredient]()

        let task = NSURLSession.sharedSession().dataTaskWithURL(fetchUrl) {(data, response, error) in
            (recipes, ingredients) = self.parseApiData(data!)
        }
        
        task?.resume()

        return (recipes, ingredients)
    }

    func parseApiData(data: NSData) -> ([Recipe], [Ingredient]) {
        do {
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            let recipesArray = jsonDictionary.valueForKey("posts") as! Array<NSDictionary>
        } catch {

        }

        return ([], [])
    }
}