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
    var calories = [String]()
    var totalSpentCals: Int = 0
    var numCalsArray = [Int]()
     var array = [String]()
    @IBOutlet weak var calorieTextBox: UITextField!
    @IBOutlet weak var foodDescription: UITextField!
    @IBOutlet weak var spent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().isPersistenceEnabled = true
        dbRef = Database.database().reference().child("jacksavagery")
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
            let sweet = CalorieEntry(calories: sweetContent, description: food, dateTime: now, addedByUser: "jacksavagery")// this creates a sweet object we can pass along to firebase
            let sweetRef = self.dbRef.child(now) // creates a reference for the sweet
            sweetRef.setValue(sweet.toAnyObject())
        }
        
    }
    
    func pullData(){
        let ref = Database.database().reference()
        let bar = ref.child("jacksavagery").observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                if let aDictionary = snapshot.value as? NSDictionary {
                    for artists in aDictionary.keyEnumerator() {
                        if let aKey = artists as? String {
                            self.array.append(aKey)
                            // print(("-----B------\n\n HERE IS THE SAUCE: \(aKey) \n\n-------E------"))
                        }
                    }
                }
            } else {
                print("no data")
            }
           // print(("-----B------\n\n HERE IS THE SAUCE: \(array) \n\n-------E------"))
            self.dateReorganizer()
        }) { (error) in
            print(error)
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
//
        
    }
    
    func dateReorganizer() {
        var convertedArray: [Date] = []
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        
        for dat in self.array {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArray.append(date)
            }
        }
        
        var actualConversion = convertedArray.sorted(by: {$0.compare($1) == .orderedAscending})
        print(("-----B------\n\n HERE IS THE SAUCE: \(actualConversion) \n\n-------E------"))
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

