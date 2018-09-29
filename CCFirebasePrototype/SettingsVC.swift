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

protocol ObtainData {
    func didFetchData(data: String)
}

class SettingsVC: UIViewController, ObtainData {
    var ref = Database.database().reference()
    var reference: DatabaseReference!
    let userID = Auth.auth().currentUser?.uid
    var userEntry: UserEntry!
    var key = ""
    var calorieLimitFromFB = ""
    var calorieEntry = ""
    var desc = ""
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
        lastCalLimit()
        print(calorieLimitFromFB)
        // this set's the standard calorie limit to 0 unless a limit has been entered.
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
    
    func findLastCalorieLimitSetting(handler: @escaping (String) -> Void) {
        ref.root.child(userID!).queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            var dictData: [String:Any] = [:]
            var di: [String:String] = [:]
            var key = ""
            var calorieLimitFinal = ""

            if let diData = snapshot.value as? [String:Any] {
                    dictData = diData
            }
            if let datar = dictData.keys.first {
                key = datar
            }
            if let actualData = dictData[key] as? [String:String] {
                di = actualData
            }
            if let calLimit = di["calorieLimit"] {
                calorieLimitFinal = calLimit
            }
            
           // let caLimFin =
            print("Here is the key: \(calorieLimitFinal)")
            self.didFetchData(data: calorieLimitFinal)
            handler(calorieLimitFinal)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func didFetchData(data: String) {
        self.calorieLimitFromFB = data
        let pulledCalorieLimit = UserDefaults.standard.string(forKey: userDefaultsCalorieLimitKey) ?? calorieLimitFromFB
        calorieLimit?.text = pulledCalorieLimit
    }
    

    func lastCalLimit() {
        var lastValue = ""
        self.findLastCalorieLimitSetting() { (handler) in
            lastValue = handler
        }
    }

    
    
    func value(snapshot: DataSnapshot) {
        let value = snapshot.value as? NSDictionary
        let calorieLimitFromFB = value?["calorieLimit"] as? String ?? ""
    }
    
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

