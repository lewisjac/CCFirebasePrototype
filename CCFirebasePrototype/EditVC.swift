 //
//  EditVC.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/21/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
 
class EditVC: UIViewController {
    var ref = Database.database().reference()
    var reference: DatabaseReference!
    var userEntry: UserEntry!
    var key = ""
    var calorieLimit = ""
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet var desc: UITextField?
    @IBOutlet var calorieEntry: UITextField?
    @IBOutlet var datePicker: UIDatePicker?
    
    init(ref: UserEntry) {
        super.init(nibName: nil, bundle: nil)

        if let tempKey = ref.itemRef?.key {
            self.key = tempKey
        }

        UserDefaults.standard.set(self.key, forKey: "key") // if this is not saved at this point it will go out of memory.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setEntryValues()
    }

    
    func setEntryValues(){
        let pulledKey = UserDefaults.standard.string(forKey: "key") ?? ""
        // Set Descriptoin
        ref.root.child(userID!).child(pulledKey).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
                        // Get user value
            let value = snapshot.value as? NSDictionary
            self.calorieEntry?.text = value?["calorieEntry"] as? String ?? ""
            self.calorieLimit = value?["calorieLimit"] as? String ?? ""
            let dateTime = value?["dateTime"] as? String ?? ""
            self.desc?.text = value?["description"] as? String ?? ""
            
            
            // let user = User(username: username)

            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
        
        // Set DatePicker
        print(pulledKey)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        let date = dateFormatter.date(from: pulledKey)
        self.datePicker?.datePickerMode = .dateAndTime
        self.datePicker?.setDate(date!, animated: false)
    }
    

    
    
    
    // how do we import the keys to this point here?
    func updateValues() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        let date = dateFormatter.string(from: (datePicker?.date)!)
        let key = UserDefaults.standard.string(forKey: "key") ?? ""
       // let pulledCalorieLimit = UserDefaults.standard.string(forKey: "calorieLimit") ?? "0"
        Database.database().reference().root.child(userID!).child(key).updateChildValues(["calorieEntry" : calorieEntry?.text! ?? "",
                                                                                                 "calorieLimit" : self.calorieLimit,
                                                                                                 "dateTime" : date,
                                                                                                 "description" : desc?.text! ?? ""
            ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateValues()
      //  navigationController?.popViewController(animated: true)
    }

    
}
