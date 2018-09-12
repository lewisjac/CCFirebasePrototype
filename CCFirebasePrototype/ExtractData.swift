//
//  ExtractData.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/4/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import Foundation

class ExtractData {
    static let sharedInstance = ExtractData(desc: "", addedByUser: "", calorieEntry: "", dateTime: "")

    var desc: String
    var addedByUser: String
    var calorieEntry: String
    var dateTime: String
    var apDat = [String]()
    var numCalsArray = [Int]()
    
    init(desc: String, addedByUser: String, calorieEntry: String, dateTime: String) {
        self.desc = desc
        self.addedByUser = addedByUser
        self.calorieEntry = calorieEntry
        self.dateTime = dateTime
        appendDatar(calorieEntry)
    }
    
    func appendDatar(_ cals: String) {
        print("\n\n\nHere's an entry: \(cals)\n\n\n")
        if let apData = UserDefaults.standard.array(forKey: "array2") as? [String] {
            apDat = apData
        }
        apDat.append(cals)
        UserDefaults.standard.set(apDat, forKey: "array2")
    }
    
    func totalCalories() -> String {
        var calAsNum = 0
        var totalSpentCals = 0
        
        for calorie in apDat {
            if calorie != "" {
                calAsNum = Int(calorie)!
                self.numCalsArray.append(calAsNum)
            }
        }
        
        for num in numCalsArray {
            totalSpentCals += num
        }
        
        let stringNum = String(totalSpentCals)
        
        return stringNum
    }
    
}
