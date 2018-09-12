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
    var ref: DatabaseReference!
    var totalCals: Int = 0
    var entries = [CalorieEntry]()
    var extractData = [ExtractData]()
    var calories = [String]()
    var totalSpentCals: Int = 0
    var numCalsArray = [Int]()
    @IBOutlet weak var calorieTextBox: UITextField!
    @IBOutlet weak var foodDescription: UITextField!
    @IBOutlet weak var spent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().isPersistenceEnabled = true
        dbRef = Database.database().reference().child("entry-entry")
        pullData()
       // totalCalories()
        
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
            let sweet = CalorieEntry(calories: sweetContent, description: food, dateTime: now, addedByUser: "lewisjac12")// this creates a sweet object we can pass along to firebase
            let sweetRef = self.dbRef.child(now) // creates a reference for the sweet
            sweetRef.setValue(sweet.toAnyObject())
        }
        
    }
    
    func pullData(){
        ref = Database.database().reference()
        ref.child("entry-entry").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print(value)

        
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        /*
            NEXT STEPS:
            Change the Firebase Data Structure to use a username as the main form of storage.
            When calling, it can then use that as a child as well, gaining simple access to
            all of the necessary data.
 
        */
        
        
        
        
        
        
         //        accessing the data from Firebase is the very last thing the program does, so it wil print what is outside the following function before it prints what is inside the function.d


        func completionHandler(snapshot: DataSnapshot?) {
            if let datas = snapshot?.children.allObjects as? [DataSnapshot] {
                let results = datas.compactMap({ // was .flatMap
                    ($0.value as! [String: Any])["calorieEntry"]
                })
                print("here are the results: \(results)")
                self.calories = results as! [String]
                print("\n\n\n call array in the function: \(self.calories)\n\n\n")
            }
        }

       // Database.database().reference().child("entry-entry").observeSingleEvent(of: .childAdded, with: nil)


        Database.database().reference().child("entry-entry").observe(.value) { snapshot in
            if let datas = snapshot.children.allObjects as? [DataSnapshot] {
                let results = datas.compactMap({ // was .flatMap
                    ($0.value as! [String: String])["calorieEntry"]
                })
                print("here are the results: \(results)")
                self.themResults(thems: results)
                self.calories = results as! [String]
                self.displayTotalSpent()
               


            }
        }

    
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
        print("Thems results: \(numCalArray)")
        
        for x in numCalArray {
            totalCals += x
        }
        print("TOTAL CALORIES EVAR: \(totalCals)")
        self.totalCals = totalCals
        print("FROM THE TOP: \(self.totalCals)")
    }
    
   /*
    func totalCalories(array: [String]) {
        var calAsNum = 0
        /*let calArray = pullData()
        for calorie in calArray {
            if calorie != "" {
                calAsNum = Int(calorie)!
                self.numCalsArray.append(calAsNum)
            }
        }
 */
        
        for num in numCalsArray {
            totalSpentCals += num
        }
        print("\n The total spent calories from the totalCalories(array:) function is: \(totalSpentCals)\n")
        let stringNum = String(totalSpentCals)
        

    }
 */
 
    
    func displayTotalSpent() {
        spent.text = String(self.totalCals)
    }

}

