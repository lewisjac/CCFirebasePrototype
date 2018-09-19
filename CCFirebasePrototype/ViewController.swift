//
//  ViewController.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/3/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    var dbRef: DatabaseReference!
    var totalCals: Int = 0
    var entries = [CalorieEntry]()
    var calories = [Int]()
    var dates = [Date]()
    var totalSpentCals: Int = 0
    var numCalsArray = [Int]()
    var keyDateArray = [String]() // this array holds the keys which gain access to the values in the fb databse
    
    @IBOutlet weak var calorieTextBox: UITextField!
    @IBOutlet weak var foodDescription: UITextField!
    @IBOutlet weak var spent: UILabel!
    @IBOutlet weak var cache: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().isPersistenceEnabled = true
        self.dbRef = Database.database().reference().child("jacksavagery")
        pullKeysFromFirebase()
        
    }
    
    
    func startObservingDB() {
        dbRef.observe(.value, with: {(snapshot: DataSnapshot) in
            var newSweets = [CalorieEntry]()
            
            for sweet in snapshot.children {
                let sweetObject = CalorieEntry(snapshot: sweet as! DataSnapshot)
                newSweets.append(sweetObject)
            }
            
            self.entries = newSweets
            //  self.tableView.reloadData()
            
        }, withCancel: {(error: Error) in
            print(error.localizedDescription)
        })
    }
    
    
    
    @IBAction func addCalories(_ sender: UIButton) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        let now = formatter.string(from: date)
        let userEnteredCalories = calorieTextBox.text
        var food = ""
        if let desc = foodDescription.text {
            food = desc
        }
        
        if let sweetContent = userEnteredCalories {
            let sweet = CalorieEntry(calories: sweetContent, description: food, dateTime: now, calorieLimit: "2500")// this creates a sweet object we can pass along to firebase
            let sweetRef = self.dbRef.child(now) // creates a reference for the sweet
            sweetRef.setValue(sweet.toAnyObject())
        }
        
        calorieTextBox.text = ""
        foodDescription.text = ""
    }
    
    
    func pullKeysFromFirebase(){
        // Pulls all keys from the provided username. The keys are the exact date and time of each calorie entry.
        let databaseObservance = self.dbRef.observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                if let aDictionary = snapshot.value as? NSDictionary {
                    for value in aDictionary.keyEnumerator() {
                        if let aKey = value as? String {
                            self.keyDateArray.append(aKey)
                        }
                    }
                }
            } else {
                print("no data")
            }
            let arrayOfOrderedDates = self.organizeDatesOldestToNewest()
            self.pullCaloriesFromFirebase()
        }) { (error) in
            print(error)
        }
    }
    
    // Find the last seven days worth of calories including those spent today
    func lastSevenDates(dates: [String]) -> [String] {
        let datesAsStringArray = dates
        var convertedArrayAsTypeDate: [Date] = []
        var convertedArrayAsTypeString: [String] = []
        var arrayOfLastSevenDays = [Date]()
        
        // Converts strings to dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        for date in datesAsStringArray {
            let date = dateFormatter.date(from: date)
            if let date = date {
                convertedArrayAsTypeDate.append(date)
            }
        }
        
        // Find last seven days of calories starting with the most recent calorie entry
        let keysAsDates = convertedArrayAsTypeDate.sorted(){$0 < $1}
        var index = keysAsDates.count - 1
        let currentDate = Date()
        let sevenDaysAgo = Date() - 7
        
        while index > -1 {
            if convertedArrayAsTypeDate[index] > sevenDaysAgo {
                arrayOfLastSevenDays.append(convertedArrayAsTypeDate[index])
            }
            index -= 1
        }
        
        for date in keysAsDates {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
            let convdate = dateFormatter.string(from: date)
            convertedArrayAsTypeString.append(convdate)
        }
        
        return convertedArrayAsTypeString
    }
    
    // Find keys for each day's last calorie entry which includes the user's final calorie limit setting for that day
    func findEndOfDayCacheLimit(dates: [String]) -> [String] {
        let datesAsStringArray = dates
        var convertedArrayAsTypeDate: [Date] = []
        var convertedArrayAsTypeString: [String] = []
        var arrayOfLastSevenDays = [Date]()
        
        // Converts strings to dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        for date in datesAsStringArray {
            let date = dateFormatter.date(from: date)
            if let date = date {
                convertedArrayAsTypeDate.append(date)
            }
        }
        
        let keysAsDates = convertedArrayAsTypeDate.sorted(){$0 < $1}
        print("This is the order of the dates \(keysAsDates)")
        var index = keysAsDates.count - 1
        let currentDate = Date()
        let sevenDaysAgo = Date() - 7
        
        // poentiall use the following:
        /*
 
         https://classictutorials.com/2015/07/how-to-get-current-day-month-and-year-in-nsdate-using-swift/
         
        */
        // Find the last date in the day by comparing it to the next date, if the day does not match, append, else continue.
        // 1. pull the day from
        
        while index > -1 {
            if convertedArrayAsTypeDate[index] > sevenDaysAgo {
                arrayOfLastSevenDays.append(convertedArrayAsTypeDate[index])
            }
            index -= 1
        }
        
        for date in keysAsDates {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
            let convdate = dateFormatter.string(from: date)
            convertedArrayAsTypeString.append(convdate)
        }
        
        
        
        let strang = [""]
        return strang
    }
    
    
    // Find calories that have been spent since 12AM today
    func todaysDates(dates: [String]) -> [String] {
        
        let datesAsStringArray = dates
        var convertedArrayAsTypeDate: [Date] = []
        var convertedArrayAsTypeString: [String] = []
        var arrayOfLastSevenDays = [Date]()
        
        // Converts strings to dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        for date in datesAsStringArray {
            let date = dateFormatter.date(from: date)
            if let date = date {
                convertedArrayAsTypeDate.append(date)
            }
        }
        
        // Find calories only from today
        let keysAsDates = convertedArrayAsTypeDate.sorted(){$0 < $1}
        var index = keysAsDates.count - 1
        let currentDate = Date()
        let cal = Calendar(identifier: .gregorian)
        let beginningOfCurrentDay = cal.startOfDay(for: currentDate)
        print("\n\nBeginning of current day: \(beginningOfCurrentDay)\n\n")
        print("Current Date: \(currentDate)")
        
        while index > -1 {
            print("Index \(index): \(convertedArrayAsTypeDate[index])")
            if convertedArrayAsTypeDate[index] > beginningOfCurrentDay {
                arrayOfLastSevenDays.append(convertedArrayAsTypeDate[index])
            }
            index -= 1
            print("Index decremented to: \(index)")
        }
        
        for date in arrayOfLastSevenDays {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
            let convdate = dateFormatter.string(from: date)
            convertedArrayAsTypeString.append(convdate)
        }
        
        print(convertedArrayAsTypeString)
        return convertedArrayAsTypeString
        
    }
    
    // Removes duplicates from the array of dates and provides a String array of dates
    func organizeDatesOldestToNewest() -> [String] {
        var convertedArray: [Date] = []
        
        // Converts strings to dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        for date in self.keyDateArray {
            let date = dateFormatter.date(from: date)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        var datesOrderedByAscending = self.keyDateArray.sorted(by: {$0.compare($1) == .orderedAscending})
        
        // REMOVE DATE REPEATS
        // First while loop sets a base value and increments through the 'datesOrderedByAscending' array when the second while loop completes
        // Second while loop iterates over every date in the 'datesOrderedByAscending' array, if no matching date is found it it sets noMatchingDates to true which allows the while loop to increment to the next date in the array to compare the base date. If a matching date is found, it is removed from the array.
        
        var index = 0
        
        while index < datesOrderedByAscending.count {
            var index_2 = index + 1
            let baseDate = datesOrderedByAscending[index]
            while index_2 < datesOrderedByAscending.count { // what's going on here: if index2 is less than the number of dates
                var noMatchingDates = false
                if baseDate == datesOrderedByAscending[index_2] {
                    //  print("Index: \(index) Base Value: \(baseValue), Pending: \(datesOrderedByAscending[index_2])")
                    datesOrderedByAscending.remove(at: index_2)
                } else {
                    noMatchingDates = true
                }
                
                if noMatchingDates == true {
                    index_2 += 1
                }
            }
            index += 1
        }
        
        return(datesOrderedByAscending)
    }
    
    func pullCaloriesFromFirebase() {
        let lastSevenDaysOfKeys = lastSevenDates(dates: organizeDatesOldestToNewest())
        let todaysCalorieKeys = todaysDates(dates: organizeDatesOldestToNewest())
        let cacheKeys = findEndOfDayCacheLimit(dates: organizeDatesOldestToNewest())
        
        print("Calorie Keys for Today: \(todaysCalorieKeys)")
        var lastSevenDaysOfCaloriesAsIntArray = [Int]()
        var lastSevenDaysOfCalorieLimitsAsIntArray = [Int]()
        var todayCaloriesAsIntArray = [Int]()
        var sevenDayCalorieLimitArray = [Int]()
        var index = 0
        var indexToday = 0
        var dictData = [String:Any]()
        let ref = Database.database().reference().child("jacksavagery")
        
        
        // Start observing firebase values
        ref.observe(.value, with: { (snapshot) in
            dictData = snapshot.value as! [String:Any]
            
             // Find last seven days worth of calories
            while index < lastSevenDaysOfKeys.count {
                let date = lastSevenDaysOfKeys[index]
                if let valuesStoredInDict = dictData[date] as? [String:Any] {
                    let dictValsForDate = valuesStoredInDict
                    if let dictValsSortedAsDict = dictValsForDate as? [String:String] {
                        let valueforDate = dictValsSortedAsDict
                        if let caloriesFromDictForDate = valueforDate["calorieEntry"] {
                            let calorieAsString = caloriesFromDictForDate
                            if calorieAsString != "" {
                                let intCal = Int(calorieAsString)
                                lastSevenDaysOfCaloriesAsIntArray.append(intCal!)
                            }
                        }
                    }
                }
                
                index += 1
            }
            let sevenDayCalTotal = lastSevenDaysOfCaloriesAsIntArray.reduce(0,+)
            self.calories = lastSevenDaysOfCaloriesAsIntArray
            print("\n\n\n The last seven days worth of calories: \(sevenDayCalTotal) \n\n\n")
            self.passedCaloriesArray(thems: lastSevenDaysOfCaloriesAsIntArray)
            
            // Find Today's Calories
            while indexToday < todaysCalorieKeys.count {
                let date = todaysCalorieKeys[indexToday]
                if let valuesStoredInDict = dictData[date] as? [String:Any] {
                    let dictValsForDate = valuesStoredInDict
                    if let dictValsSortedAsDict = dictValsForDate as? [String:String] {
                        let valueforDate = dictValsSortedAsDict
                        if let caloriesFromDictForDate = valueforDate["calorieEntry"] {
                            let calorieAsString = caloriesFromDictForDate
                            if calorieAsString != "" {
                                let intCal = Int(calorieAsString)
                                todayCaloriesAsIntArray.append(intCal!)
                            }
                        }
                    }
                }
                
                indexToday += 1
            }
            
            let todayCalTotal = todayCaloriesAsIntArray.reduce(0,+)
            self.calories = todayCaloriesAsIntArray
            print("\n\n\n Today's spent calories: \(todayCalTotal) \n\n\n")
            self.displayTotalSpent(caloriesSpent: todayCalTotal)
 /////////////////////////////////////////////////////////////////////////////////////////////////
           
            // Find Last Seven Days of cache limit
            while index < lastSevenDaysOfKeys.count {
                let date = lastSevenDaysOfKeys[index]
                if let valuesStoredInDict = dictData[date] as? [String:Any] {
                    let dictValsForDate = valuesStoredInDict
                    if let dictValsSortedAsDict = dictValsForDate as? [String:String] {
                        let valueforDate = dictValsSortedAsDict
                        if let calorieLimitFromDictForDate = valueforDate["calorieLimit"] {
                            let calorieLimitAsString = calorieLimitFromDictForDate
                            if calorieLimitAsString != "" {
                                let calLimit = Int(calorieLimitAsString)
                                lastSevenDaysOfCalorieLimitsAsIntArray.append(calLimit!)
                            }
                        }
                    }
                }
                
                index += 1
            }
            let sevenDayCalLimitTotal = lastSevenDaysOfCalorieLimitsAsIntArray.reduce(0,+)
            self.calories = lastSevenDaysOfCalorieLimitsAsIntArray
            print("\n\n\n The last seven days worth of calories: \(sevenDayCalLimitTotal) \n\n\n")
           // self.passedCaloriesArray(thems: lastSevenDaysOfCalorieLimitsAsIntArray)
        })
    }
    
    
    func passedCaloriesArray(thems: [Int]) {
        self.calories = thems
        print("THE CALORIES: \(self.calories)")
        
    }
    
    func displayTotalSpent(caloriesSpent today: Int) {
        spent.text = String(today)
    }
    
    func displayCacheValue(calorieLimitTotal: Int, calorieSpentTotal: Int) {
        let limit = calorieLimitTotal
        let spent = calorieSpentTotal
        let cache = limit - spent
        
    }
}

