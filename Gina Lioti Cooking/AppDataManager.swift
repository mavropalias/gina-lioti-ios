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

    var recipes: [Recipe]?
    var ingredients: [Ingredient]?

    init() {
        (recipes, ingredients) = coreDataManager.load()

        if shouldFetchFromAPI() {
            (recipes, ingredients) = api.fetch()
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