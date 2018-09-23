//
//  Settings.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/22/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class SettingsVC: UIViewController {
    var ref = Database.database().reference()
    var reference: DatabaseReference!
    @IBOutlet weak var calorieLimit: UITextField?
    
    override func viewDidLoad() {
        let pulledCalorieLimit = UserDefaults.standard.string(forKey: "calorieLimit") ?? "0"
        calorieLimit?.text = pulledCalorieLimit // this set's the standard calorie limit to 0 unless a limit has been entered.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateCalorieLimit()
    }
    
    func updateCalorieLimit() {
        let calLimit = calorieLimit?.text
        UserDefaults.standard.set(calLimit, forKey: "calorieLimit")
        
        ref.root.child("jacksavagery").childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
           
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

