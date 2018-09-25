//
//  ViewController.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/3/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//
//
//
//
// REMOVE SWEET REFERENCE!
//
//
//
//
//
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    var dbRef: DatabaseReference!
    var totalCals: Int = 0
    var entries = [UserEntry]()
    var calories = [Int]()
    var dates = [Date]()
    var totalSpentCals: Int = 0
    var numCalsArray = [Int]()
    var keyDateArray = [String]() // this array holds the keys which gain access to the values in the fb databse
    
    @IBOutlet weak var calorieTextBox: UITextField?
    @IBOutlet weak var foodDescription: UITextField?
    @IBOutlet weak var spent: UILabel?
    @IBOutlet weak var cache: UILabel?
    @IBOutlet weak var remaining: UILabel?
    @IBOutlet weak var dateTime: UIDatePicker?
    
    @IBAction func calorieValueChanged(_ sender: UITextField) {
        if let last = sender.text?.last {
            let zero: Character = "0"
            let num: Int = Int(UnicodeScalar(String(last))!.value - UnicodeScalar(String(zero))!.value)
            if (num < 0 || num > 9) {
                //remove the last character as it is invalid
                sender.text?.removeLast()
            }
        }
    }
    
    @IBAction func diaryButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let diaryView = storyboard.instantiateViewController(withIdentifier: "TableVC") as! UITableViewController
        self.navigationController?.pushViewController(diaryView, animated: true)

    }
    
    @IBAction func settingsButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.navigationController?.pushViewController(nextView, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().isPersistenceEnabled = true
        self.dbRef = Database.database().reference().child("jacksavagery")
        pullKeysFromFirebase()
    }
    
    
    // add functionality that blocks the user from:
    // 1. entering anything other than numbers into calories
    // 2. not entering anything.
    @IBAction func addCalories(_ sender: UIButton) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        let now = formatter.string(from: date)
        var calEntryDate = ""
        if let tempPickerDate = self.dateTime?.date {
            calEntryDate = formatter.string(from: tempPickerDate)
        }
        print(calEntryDate)
        var userCalories = ""
        if let userEnteredCalories = calorieTextBox?.text {
            userCalories = userEnteredCalories
        }
        var food = ""
        if let desc = foodDescription?.text {
            if desc == "" {
                food = "Nondescript food item"
            } else {
                food = desc
            }
        }

        // prevent user's from entering 0 calories 
        if CharacterSet.letters.isSubset(of: CharacterSet(charactersIn: userCalories)) == true {

        } else {
            if let userEntry = calorieTextBox?.text {
                let aNewDay = newDay(date: calEntryDate)
                let pulledCalorieLimit = UserDefaults.standard.string(forKey: "calorieLimit") ?? "0"
                let sweet = UserEntry(calories: userEntry, description: food, dateTime: calEntryDate, calorieLimit: pulledCalorieLimit, newDay: aNewDay)// this creates a sweet object we can pass along to firebase
                let sweetRef = self.dbRef.child(calEntryDate) // creates a reference for the sweet
                sweetRef.setValue(sweet.toAnyObject())
            }
            
            calorieTextBox?.text = ""
            foodDescription?.text = ""
        }
    }
    
    // determine if new entry is for a new day
    func newDay(date: String) -> String {
        var dateToReturn = ""
        let newDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        let latestEntry = dateFormatter.date(from: newDate)
        var keys = [""]
        if let endOfDayKeys = UserDefaults.standard.array(forKey: "endOfDayLimits") as? [String] {
            keys = endOfDayKeys
        }
        let index = keys.count - 1
        let lastDayKey = keys[0]
        let lastDate = dateFormatter.date(from: lastDayKey)
        dateFormatter.dateFormat = "dd"
        let priorDate = Int(dateFormatter.string(from: lastDate!))!
        let currentDate = Int(dateFormatter.string(from: latestEntry!))!
        
        if priorDate != currentDate {
            print("\(priorDate) vs \(currentDate)")
            
     
            
            dateFormatter.dateFormat = "MMM dd"
            if let dayToReturn = latestEntry {
                dateToReturn = dateFormatter.string(from: dayToReturn)
            }
            
            print("THIS IS THE DATE THAT WILL RETURN: \(dateToReturn)")

            
        } else {
            dateToReturn = ""
        }
       
        return dateToReturn
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
        let now = Date()
        let sevenDaysFromNow = now.addingTimeInterval(7*24*3600)
        let difference = sevenDaysFromNow.timeIntervalSinceNow
        let sevenDaysAgo = now - difference
        
        while index > -1 {
            if convertedArrayAsTypeDate[index] > sevenDaysAgo {
                arrayOfLastSevenDays.append(convertedArrayAsTypeDate[index])
             print("\n\n\n Added: \(convertedArrayAsTypeDate[index]) \n\n\n ")
            } else {
                break
            }
            index -= 1
        }
        
        for date in arrayOfLastSevenDays {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
            let convdate = dateFormatter.string(from: date)
            convertedArrayAsTypeString.append(convdate)
        }
        print("\n\n\n\n\n\n\n\n\n HERE IS THE ARRAY: \(convertedArrayAsTypeString) \n\n\n\n\n\n\n\n\n")
        return convertedArrayAsTypeString
    }
    
    // Find keys for each day's last calorie entry which includes the user's final calorie limit setting for that day
    func findEndOfDayCalLimit(dates: [String]) -> [String] {
        let datesAsStringArray = dates
        var convertedArrayAsTypeDate: [Date] = []
        var convertedArrayAsTypeString: [String] = []
        // var arrayOfLastSevenDays = [Date]()
        var arrayOfLastSevenCalLimitKeys = [Date]()
        var arrayOfLastSevenCalLimitShortDays = [Int]()
        
        // Converts strings to dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        for date in datesAsStringArray {
            let date = dateFormatter.date(from: date)
            if let date = date {
                convertedArrayAsTypeDate.append(date)
            }
        }
        
        let keysAsDates = convertedArrayAsTypeDate.sorted(){$0 < $1} // orders dates least to greatest
        print("This is the order of the dates \(keysAsDates)")
        var index = keysAsDates.count - 1
        
        
        // dates being comapaired need to be the actual day.
        let now = Date()
        let sevenDaysFromNow = now.addingTimeInterval(7*24*3600)
        let difference = sevenDaysFromNow.timeIntervalSinceNow
        var sevenDaysAgo = now - difference
        print("seven days ago: \(sevenDaysAgo)")
        var valueA = Date()
        var valueB = Date()
        
        // find the last calorieLimit for each day
        while index > -1 {
            print("\(keysAsDates[index]) vs. \(sevenDaysAgo)")
            if keysAsDates[index] > sevenDaysAgo {
                print("\n\nIT'S TRUE! IT'S TRUE!\n\n")
            }
            if keysAsDates[index] > sevenDaysAgo {
                print("\n\(keysAsDates[index]) was included\n")
                valueA = keysAsDates[index]
                let valueA_Day = Calendar.current.component(.day, from: valueA)
                
                if index == 0 {
                    arrayOfLastSevenCalLimitKeys.append(keysAsDates[index])
                    arrayOfLastSevenCalLimitShortDays.append(valueA_Day)
                    
                } else {
                    
                    valueB = keysAsDates[index - 1]
                    let valueB_Day = Calendar.current.component(.day, from: valueB)
                    
                    
                    if index == keysAsDates.count - 1 {
                        arrayOfLastSevenCalLimitKeys.append(keysAsDates[index])
                        arrayOfLastSevenCalLimitShortDays.append(valueA_Day)
                        index -= 1
                        
                    } else if valueA_Day != valueB_Day  {
                        for value in arrayOfLastSevenCalLimitShortDays { // this is looking at an explicit day and is useleses
                            if valueA_Day == value {
                                break
                            } else {
                                arrayOfLastSevenCalLimitKeys.append(keysAsDates[index])
                            }
                        }
                    }
                }
                index -= 1
            } else {
            break
            }
        }
        
    
                print("Keys for end limits: \(arrayOfLastSevenCalLimitKeys)")
        

        
        
        for date in arrayOfLastSevenCalLimitKeys {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
            let convdate = dateFormatter.string(from: date)
            convertedArrayAsTypeString.append(convdate)
        }
        
        
     
        return convertedArrayAsTypeString
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

        
        while index > -1 {
            if convertedArrayAsTypeDate[index] > beginningOfCurrentDay {
                arrayOfLastSevenDays.append(convertedArrayAsTypeDate[index])
            }
            index -= 1
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
        let arrayOfCalorieLimits = findEndOfDayCalLimit(dates: organizeDatesOldestToNewest())
        UserDefaults.standard.set(arrayOfCalorieLimits, forKey: "endOfDayLimits")
        let lastCalorieLimitEntry = arrayOfCalorieLimits.count - 1
        var lastCalLimitEntry = 0
        var lastSevenDaysOfCaloriesAsIntArray = [Int]()
        var lastSevenDaysOfCalorieLimitsAsIntArray = [Int]()
        var todayCaloriesAsIntArray = [Int]()
        var sevenDayCalorieLimitArray = [Int]()
        var index = 0
        var indexToday = 0
        var indexCalorieLimit = 0
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
                                let intCal = Int(calorieAsString) //calorieAsString
                                lastSevenDaysOfCaloriesAsIntArray.append(intCal!)
                              //  print("\n\n\n ADDED: \(intCal) \n\n\n ")
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
                            if calorieAsString != "" && calorieAsString != "lk" {
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
            
           
            // Find Last Seven Days of calorie limits
            while indexCalorieLimit < arrayOfCalorieLimits.count {
                let date = arrayOfCalorieLimits[indexCalorieLimit]
                if let valuesStoredInDict = dictData[date] as? [String:Any] {
                    let dictValsForDate = valuesStoredInDict
                    if let dictValsSortedAsDict = dictValsForDate as? [String:String] {
                        let valueforDate = dictValsSortedAsDict
                        if let calorieLimitFromDictForDate = valueforDate["calorieLimit"] {
                            let calorieLimitAsString = calorieLimitFromDictForDate
                            if calorieLimitAsString != "" && calorieLimitAsString != "lk" {
                                let calLimit = Int(calorieLimitAsString)
                                lastSevenDaysOfCalorieLimitsAsIntArray.append(calLimit!)
                            }
                        }
                    }
                }
                
                indexCalorieLimit += 1
            }
            
            // Find Last Calorie Limit Setting
//            let date = arrayOfCalorieLimits[lastCalorieLimitEntry]
//            if let valuesStoredInDict = dictData[date] as? [String:Any] {
//                let dictValsForDate = valuesStoredInDict
//                if let dictValsSortedAsDict = dictValsForDate as? [String:String] {
//                    let valueforDate = dictValsSortedAsDict
//                    if let calorieLimitFromDictForDate = valueforDate["calorieLimit"] {
//                        let calorieLimitAsString = calorieLimitFromDictForDate
//                        if calorieLimitAsString != "" {
//                            lastCalLimitEntry = calLimitAsInt
//                        }
//                    }
//                }
//            }
//
            let pulledCalorieLimit = UserDefaults.standard.string(forKey: "calorieLimit") ?? "0"
            let calLimitAsInt = Int(pulledCalorieLimit)!
            let sevenDayCalLimitTotal = lastSevenDaysOfCalorieLimitsAsIntArray.reduce(0,+)
            self.calories = lastSevenDaysOfCalorieLimitsAsIntArray
            print("\n\n\n The last seven calorie limit: \(sevenDayCalLimitTotal) \n\n\n")
            self.displayCacheValue(caloriesSpent: todayCalTotal, calorieLimitTotal: sevenDayCalLimitTotal, calorieSpentTotal: sevenDayCalTotal, lastCalorieLimit: calLimitAsInt)
            
        })
    }
    
    
    func passedCaloriesArray(thems: [Int]) {
        self.calories = thems
        print("THE CALORIES: \(self.calories)")
        
    }
    
    func displayTotalSpent(caloriesSpent today: Int) {
        spent?.text = String(today)
    }
    
    // Cached values are only updating based on todays values when edited in diary.
    func displayCacheValue(caloriesSpent: Int, calorieLimitTotal: Int, calorieSpentTotal: Int, lastCalorieLimit: Int) {
        // SET:  UserDefaults.standard.set(self.key, forKey: "key")
        // GET: let key = UserDefaults.standard.string(forKey: "key") ?? ""
        // Cache needs to update upon midnight to include new availble calories.
        // if previous entry is from a a different day, enter false limit calories, else don't do anything.
        let limit = calorieLimitTotal
        let spent = calorieSpentTotal
        let lastLimitSetting = lastCalorieLimit
        let todayCaloriesSpent = caloriesSpent
        var todayRemaining = 0
        var cache = 0
        let pulledCalorieLimit = UserDefaults.standard.string(forKey: "calorieLimit") ?? "0"
        let calLimitAsInt = Int(pulledCalorieLimit)!
        
        if todayCaloriesSpent == 0 {
            cache = (limit + calLimitAsInt) - spent // 2500 needs to be replaced with user entered limit.
        } else {
            cache = limit - spent
        }
      
        todayRemaining = calLimitAsInt - todayCaloriesSpent
        self.cache?.text = String(cache)
        self.remaining?.text = String(todayRemaining)

        // Set value of remaining and spent to zero at midnight and stays until user enters new value.
        // Create function that erases data after so many days of no calorie entries.
        // create placeholder zero calorie entry for when the user misses a day.
        // Create function that checks how many days between opening the app the last time.
        print(cache)
        
    }
    
    func accountForNewAndMissedDays() {
//        ref.root.child("jacksavagery").child(pulledKey).observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot)
//
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            self.calorieEntry?.text = value?["calorieEntry"] as? String ?? ""
//            let calorieLimit = value?["calorieLimit"] as? String ?? ""
//            let dateTime = value?["dateTime"] as? String ?? ""
//            self.desc?.text = value?["description"] as? String ?? ""
//
//
//            // let user = User(username: username)
//
//            // ...
//        }) { (error) in
//            print(error.localizedDescription)
//        }
    }
    

}

