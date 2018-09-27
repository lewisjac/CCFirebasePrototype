//
//  LogInVC.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/25/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class LoginVC: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet var email: UITextField?
    @IBOutlet var password: UITextField?
    var uEmail = ""
    var uPswrd = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationItem.hidesBackButton = true
        
        

       // self.navigationController?.hidesBarsOnTap = true
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            print(auth)
            if let user = user {
                print(user)
            }
        }
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    
    @IBAction func signUp(_ sender: UIButton) {
        guard let email = self.email?.text,
            email != "",
            let password = self.password?.text,
            password != ""
            else {
                AlertController.showAlert(self, title: "!?", message: "Please provide a valid email and password")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("SUCCESS!")
                self.performSegue(withIdentifier: "firstTimeSetCalories", sender: nil)
            } else {
                print("OH NO")
            }
            guard error == nil else {
                AlertController.showAlert(self, title: "oh no!", message: error!.localizedDescription)
                return
            }
            
            guard let user = user else { return }
            print(user.user.displayName ?? "MISSING DISPLAYNAME")
            print(user.user.email ?? "MISSING EMAIL")
            print(user.user.uid)
        }

    }
    
    @IBAction func logIn(_ sender: UIButton){
        guard let email = self.email?.text,
        email != "",
        let password = self.password?.text,
        password != ""
            else {
                AlertController.showAlert(self, title: "!?", message: "Please provide a valid email and password")
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error == nil {
                print("SUCCESS!")
                self.performSegue(withIdentifier: "toViewController", sender: nil)
            } else {
                print("OH NO")
            }
            guard error == nil else {
                AlertController.showAlert(self, title: "oh no!", message: error!.localizedDescription)
                return
            }
            
            guard let user = user else { return }
            print(user.user.displayName ?? "MISSING DISPLAYNAME")
            print(user.user.email ?? "MISSING EMAIL")
            print(user.user.uid)
        }
        
        let userID = Auth.auth().currentUser?.uid
        print(userID)
    }
    
}

