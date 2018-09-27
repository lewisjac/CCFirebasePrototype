//
//  Settings.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/22/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import UIKit

class SettingsVC: UIViewController {
    var ref = Database.database().reference()
    var reference: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    var userDefaultsCalorieLimitKey = ""
    @IBOutlet weak var userEmail: UILabel?
    @IBOutlet weak var calorieLimit: UITextField?
    
    
    override func viewDidLoad() {
        userEmail?.text = Auth.auth().currentUser?.email
    
        guard let id = userID else {
            print("no id")
            return
        }
        userDefaultsCalorieLimitKey = id + "_calorieLimit"
        
        let pulledCalorieLimit = UserDefaults.standard.string(forKey: userDefaultsCalorieLimitKey) ?? "0"
        calorieLimit?.text = pulledCalorieLimit // this set's the standard calorie limit to 0 unless a limit has been entered.
         self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    

    @IBAction func setCalorieLimitButton(_ sender: UIButton) {
        let calLimit = calorieLimit?.text
        UserDefaults.standard.set(calLimit, forKey: userDefaultsCalorieLimitKey)
        
        ref.root.child(userID!).childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
        }) { (error) in
            print(error.localizedDescription)
        }
       
         self.performSegue(withIdentifier: "setCalLimit", sender: nil)
        
        let alert = UIAlertController(title: "Attention!", message: "Any change to your daily caloric limit will not be reflected in your cache until you have made a calorie entry for that day. Best not to change your limit on a whim!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "as you wish", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
       

    }
    
//    func updateCalorieLimit() {
//        let calLimit = calorieLimit?.text
//        UserDefaults.standard.set(calLimit, forKey: "calorieLimit")
//
//        ref.root.child(userID!).childByAutoId().observeSingleEvent(of: .value, with: { (snapshot) in
//            print(snapshot)
//
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
    
    @IBAction func logOut(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "toLoginVC", sender: nil)

        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

        
    }
}

