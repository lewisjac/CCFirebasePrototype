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
                        print("\n\n HERE IT IS: \(ventaes) \n\n\n\n")
                    }
                }
            }
           // let ahvailla = avalla?["calorieEntry"] as? [String:String]
          
        })
        
       //  Extract the Data from SnapShot
        var arrFetchedData:NSMutableArray = NSMutableArray()
        for data in dictData {
            let tempDict:NSMutableDictionary = NSMutableDictionary()
            let innerData = data.value as! [String:Any]
            let addedByUser = innerData["Sep 12, 2018 07:46:15"]
            print(addedByUser)
            tempDict.setValue(addedByUser, forKey: "calorieEntry")
            arrFetchedData.add(tempDict)
        }
       // print("\n\n\n THIS IS THE SUAHCE: \(arrFetchedData) \n\n\n")

        /*
            NEXT STEPS:
                The date needs to be associated with the calorie entry.
                 - aggregate all calories for the day as well as the last seven days as seperate totals
 
        */
        
        

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
//        Database.database().reference().child("jacksavagery").observe(.value) { snapshot in
//            if let datas = snapshot.children.allObjects as? [DataSnapshot] {
//
//
//                print("\n\n\n\n\n \(datas)\n\n\n\n\n")
//                let datars = datas.compactMap({ // was .flatMap
//                    ($0.value as! [String: String])["Sep 12, 2018 08:47:39"]
//                })
//                        print("\n\n\n\n\n \(datars)\n\n\n\n\n")
//
//            }
//
//            let dataers = snapshot.childSnapshot(forPath: "Sep 12, 2018 08:47:39")
//            let um = dataers.children.allObjects as? [AnyObject]
//            print("THIS?:: \(um)")
//            print("The datars: \n\n\n \(dataers) \n\n\n\n")
//            let datum = snapshot.value as? [String:String]
//            print(datum)
//        }
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

