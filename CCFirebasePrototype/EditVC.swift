//
//  EditVC.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/21/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import Foundation
import FirebaseDatabase

class EditVC: UIViewController {
    var reference: DatabaseReference!
    var userEntry: UserEntry!
    var key = ""
    
    @IBOutlet var datePicker: UIDatePicker?
    
    
    convenience init(ref: UserEntry) {
        self.init()
    
        if let tempKey = ref.itemRef?.key {
            self.key = tempKey
        }
   
        updateValues(key: self.key)
        
    }
    
    func pickThatDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm"
        var dateForDatePicker = Date()
        if let date = dateFormatter.date(from: self.key)  {
            dateForDatePicker = date
        }
        let picker = datePicker
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let someDateTime = formatter.date(from: self.key)
        print(dateForDatePicker)
        
        var calendar: Calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: Date())
        components.hour = 5
        components.minute = 50
        datePicker?.setDate(someDateTime!, animated: true)
        // txtDatePicker.setDate(calendar.dateFromComponents(components)!, animated: true)

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickThatDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reference = Database.database().reference().child("jacksavagery") // change .child to reference user's login information.
       // updateValues(key: self.key)
    }
    
    
    
    // how do we import the keys to this point here?
    func updateValues(key: String) {
        let key = self.key
        print("Here is the key: \(key)")
        let post = ["calorieEntry" : "0",
                    "calorieLimit" : "2500",
                    "dateTime" : "TEST TEST TEST",
                    "description" : "TEST TEST TEST"
        ]

        let childUpdates = post
        print("CHILDUPDATES: \(childUpdates)")
       
        Database.database().reference().root.child("jacksavagery").child(key).updateChildValues(["calorieEntry": "0", "calorieLimit" : "2500", "dateTime" : "TEST TEST TEST","description" : "TEST TEST TEST"])

    }
    
}
