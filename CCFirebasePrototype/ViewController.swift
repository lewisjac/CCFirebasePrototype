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
    var calories = [String]()
    var dates = [Date]()
    var totalSpentCals: Int = 0
    var numCalsArray = [Int]()
     var array = [String]()
    @IBOutlet weak var calorieTextBox: UITextField!
    @IBOutlet weak var foodDescription: UITextField!
    @IBOutlet weak var spent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().isPersistenceEnabled = true
        self.dbRef = Database.database().reference().child("jacksavagery")
        pullData()
        
        
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
            let sweet = CalorieEntry(calories: sweetContent, description: food, dateTime: now, addedByUser: "jacksavagery")// this creates a sweet object we can pass along to firebase
            let sweetRef = self.dbRef.child(now) // creates a reference for the sweet
            sweetRef.setValue(sweet.toAnyObject())
        }
        
        calorieTextBox.text = ""
        foodDescription.text = ""
    }
    
    func pullData(){
        
        // Pulls all keys from the provided username. The keys are the exact date and time of each calorie entry.
        let bar = self.dbRef.observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                if let aDictionary = snapshot.value as? NSDictionary {
                    for artists in aDictionary.keyEnumerator() {
                        if let aKey = artists as? String {
                            self.array.append(aKey)
                        }
                    }
                }
            } else {
                print("no data")
            }
            let arrayOfOrderedDates = self.organizeDatesOldestToNewest()
            self.analyzeCalorieData(dates: arrayOfOrderedDates)
        }) { (error) in
            print(error)
        }
    }
    
    func organizeDatesOldestToNewest() -> [String] {
        var convertedArray: [Date] = []
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        
        for date in self.array {
            let date = dateFormatter.date(from: date)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        
        var datesOrderedByAscending = self.array.sorted(by: {$0.compare($1) == .orderedAscending})
     
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
    
    func analyzeCalorieData(dates: [String]) {
        var calorieArray = [String]()
        let dates = dates
        var index = 0
        var dictData = [String:Any]()
        let ref = Database.database().reference().child("jacksavagery")
        
        
        
        ref.observe(.value, with: { (snapshot) in
            // print("\n\(snapshot.value!)\n")
            dictData = snapshot.value as! [String:Any]
            while index < dates.count {
                let date = dates[index]
                if let avalla = dictData[date] as? [String:Any] {
                    //print(" HERE IS THE AVALLA: \n\n\(avalla)\n\n")
                    let vail = avalla
                    if let availluh = vail as? [String:String] {
                        let duvail = availluh
                        if let bvalli = duvail["calorieEntry"] {
                            let ventaes = bvalli
                            calorieArray.append(ventaes)
                        }
                    }
                }
               // print("\n\n\n I PRESENT THE SAUCE: \(calorieArray) \n\n\n")
                index += 1
            }
        print("\n\n\n I PRESENT THE SAUCE: \(calorieArray) \n\n\n")
        })
        
        
        
        
    }

    
    func themResults(thems: [String]) {
        var calAsNum = 0
        var totalCals = 0
        var numCalArray = [Int]()
        for calorie in thems {
            if calorie != "" {
                calAsNum = Int(calorie)!
                numCalArray.append(calAsNum)
            }
        }
     // print("Thems results: \(numCalArray)")
        
        for x in numCalArray {
            totalCals += x
        }
       // print("TOTAL CALORIES EVAR: \(totalCals)")
        self.totalCals = totalCals
       // print("FROM THE TOP: \(self.totalCals)")
    }
    

 
    
    func displayTotalSpent() {
        spent.text = String(self.totalCals)
    }

    
}


/* ---------------- Working Code that pulls out single entry ----------------------
 // Fetch Data
 var dictData = [String:Any]()
 let ref = Database.database().reference()
 ref.observe(.childAdded, with: { (snapshot) in
 //  print(snapshot.value!)
 dictData = snapshot.value as! [String:Any]
 if let avalla = dictData["Sep 12, 2018 07:46:15"] as? [String:Any] {
 let vail = avalla
 if let availluh = vail as? [String:String] {
 let duvail = availluh
 if let bvalli = duvail["calorieEntry"] {
 let ventaes = bvalli
 //     print("\n\n HERE IT IS: \(ventaes) \n\n\n\n")
 }
 }
 }
 
 
 // let ahvailla = avalla?["calorieEntry"] as? [String:String]
 
 })
 let value = ref.child("jacksavagery").childByAutoId().description()
 print("\n\n\n\n\(value)\n\n\n\n\n")
 */ // ----------------------- END WORKING CODE -------------------------------------

// Primary Data Collector
//        Database.database().reference().child("jacksavagery").observe(.value) { snapshot in
//            if let datas = snapshot.children.allObjects as? [DataSnapshot] {
//                let caloriesArray = datas.compactMap({ // was .flatMap
//                    ($0.value as! [String: String])["calorieEntry"]
//                })
//
//                let dates = datas.compactMap({
//                    ($0.value as! [String: String])["dateTime"]
//                })
//
//
//                let alternativeResults = datas.last
//                print("HERE'S WHAT YOU'RE LOOKING FUR \(dates)")
//              //  print("here are the results: \(results)")
//                self.themResults(thems: caloriesArray)
//                self.calories = caloriesArray
//                self.displayTotalSpent()
//
//            }
//        }

