//
//  DataManager.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 12/07/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import Foundation

class AppDataManager {
    lazy var api = ApiManager()

    let coreDataManager = CoreDataManager()
    let userDefaultsManager = UserDefaultsManager()
    let apiSyncIntervalHours = 24
    let printPrefix = "–––––– "

    var recipes: [Recipe]?
    var ingredients: [Ingredient]?

    init() {
        print (printPrefix + "Init app")
        (recipes, ingredients) = coreDataManager.load()
        print (printPrefix + "Loaded recipes from Core Data")

        if shouldFetchFromAPI() {
            //(recipes, ingredients) = api.fetch()
            print (printPrefix + "Loading recipes from API")
            api.fetch()
        }

    }

    func shouldFetchFromAPI() -> Bool {
        if let lastSyncDate = userDefaultsManager.lastSyncDate() {
            let currentDate = NSDate()
            if hourDifference(fromDate: lastSyncDate, toDate: currentDate) < apiSyncIntervalHours {
                return false
            }
        }

        return true
    }

    func hourDifference(fromDate startDate: NSDate, toDate endDate: NSDate) -> Int {
        let cal = NSCalendar.currentCalendar()
        let comparisonResult = cal.compareDate(startDate, toDate: endDate, toUnitGranularity: .Hour)

        return comparisonResult.rawValue
    }
}