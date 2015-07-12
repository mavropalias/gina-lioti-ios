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
        url = "http://ginalioti.com/api/get_posts/?count=100"
    }

    func fetch() -> ([Recipe]?, [Ingredient]?) {

        return (nil, nil)
    }
}