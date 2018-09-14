//
//  CalorieEntry.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/3/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//



/*
 The completed app must:
    - calculate last seven days of calories in cached calories
    - 
 */

import Foundation
import FirebaseDatabase

struct CalorieEntry {
    let key: String?
    let calories: String?
    let dateTime: String?
    let addedByUser: String?
    let description: String?
    let itemRef: DatabaseReference?
    
    init(calories: String, description: String, dateTime: String, addedByUser: String, key: String = "") {
        self.key = key
        self.calories = calories
        self.description = description
        self.dateTime = dateTime
        self.addedByUser = addedByUser
        self.itemRef = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        itemRef = snapshot.ref
        
        if let dict = snapshot.value as? NSDictionary, let calorieEntry = dict["calorieEntry"] as? String {
            calories = calorieEntry
        } else {
            calories = ""
        }
        
        if let dict = snapshot.value as? NSDictionary, let cacheUser = dict["addedByUser"] as? String {
            addedByUser = cacheUser
        } else {
            addedByUser = ""
        }
        
        if let dict = snapshot.value as? NSDictionary, let dntOfEntry = dict["dateTime"] as? String {
            dateTime = dntOfEntry
        } else {
            dateTime = ""
        }
        
        if let dict = snapshot.value as? NSDictionary, let desc = dict["description"] as? String {
            description = desc
        } else {
            description = ""
        }
        
    }
    
    func toAnyObject() -> AnyObject {
        let array = ["calorieEntry":calories, "description":description, "addedByUser":addedByUser, "dateTime":dateTime]
        return array as AnyObject
    }
}
