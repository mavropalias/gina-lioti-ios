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

    // TODO: let coreDataManager = CoreDataManager()
    let userDefaultsManager = UserDefaultsManager()
    let apiSyncIntervalHours = 24
    let printPrefix = "–––––– "

    init() {
        if shouldFetchFromAPI() {
            print (printPrefix + "Loading recipes from API")
            api.fetch()
        }

    }

    func shouldFetchFromAPI() -> Bool {
        if let lastSyncDate = userDefaultsManager.lastSyncDate() {
            let currentDate = Date()
            if hourDifference(fromDate: lastSyncDate as Date, toDate: currentDate) < apiSyncIntervalHours {
                return false
            }
        }

        return true
    }

    func hourDifference(fromDate startDate: Date, toDate endDate: Date) -> Int {
        let cal = Calendar.current()
        let comparisonResult = cal.compare(startDate, to: endDate, toUnitGranularity: .hour)

        return comparisonResult.rawValue
    }
}
