//
//  UserDefaultsManager.swift
//  Gina Lioti Cooking
//
//  Created by Kostas on 12/07/2015.
//  Copyright © 2015 gl. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    let userDefaults = NSUserDefaults.standardUserDefaults()

    func lastSyncDate() -> NSDate? {
        if let lastSyncDate = userDefaults.objectForKey("lastSync") as? NSDate {
            return lastSyncDate
        }

        return nil
    }

}