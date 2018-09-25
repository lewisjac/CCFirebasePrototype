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

struct UserEntry {
    let key: String?
    let calories: String?
    let dateTime: String?
    let calorieLimit: String?
    let description: String?
    let newDay: String?
    let itemRef: DatabaseReference?
    
    init(calories: String, description: String, dateTime: String, calorieLimit: String, newDay: String, key: String = "") {
        self.key = key
        self.calories = calories
        self.description = description
        self.dateTime = dateTime
        self.calorieLimit = calorieLimit
        self.newDay = newDay
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
        
        if let dict = snapshot.value as? NSDictionary, let calsLimit = dict["calorieLimit"] as? String {
            calorieLimit = calsLimit
        } else {
            calorieLimit = ""
        }
        
        if let dict = snapshot.value as? NSDictionary, let dntOfEntry = dict["dateTime"] as? String {
            dateTime = dntOfEntry
        } else {
            dateTime = ""
        }
        
        if let dict = snapshot.value as? NSDictionary, let new = dict["newDay"] as? String {
            newDay = new
        } else {
            newDay = ""
        }
        
        if let dict = snapshot.value as? NSDictionary, let desc = dict["description"] as? String {
            description = desc
        } else {
            description = ""
        }
        
    }
    
    func toAnyObject() -> AnyObject {
        let array = ["calorieEntry":calories, "description":description, "calorieLimit":calorieLimit, "dateTime":dateTime, "newDay":newDay]
        return array as AnyObject
    }
}
