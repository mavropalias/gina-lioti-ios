//
//  UserDefaultsManager.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 12/07/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    let userDefaults = UserDefaults.standard()

    func lastSyncDate() -> Date? {
        if let lastSyncDate = userDefaults.object(forKey: "lastSync") as? Date {
            return lastSyncDate
        }

        return nil
    }

}
