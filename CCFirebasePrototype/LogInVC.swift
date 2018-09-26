//
//  LogInVC.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/25/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth


class LogInVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBSDKLoginButton()
   //     loginButton.delegate = self as! FBSDKLoginButtonDelegate
        // Optional: Place the button in the center of your view.
        loginButton.center = view.center
        view.addSubview(loginButton)
//
//        func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let diaryView = storyboard.instantiateViewController(withIdentifier: "Dashboard") as! ViewController
//            self.navigationController?.pushViewController(diaryView, animated: true)
//        }
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
        }

        func loginButtonClicked() {
            let login = FBSDKLoginManager()
            login.logIn(withReadPermissions: ["public_profile"], from: self, handler: { result, error in
                if error != nil {
                    print("Process error")
                } else if result?.isCancelled != nil {
                    print("Cancelled")
                } else {
                    print("Logged in")
                }
            })
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    // ...
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let diaryView = storyboard.instantiateViewController(withIdentifier: "Dashboard") as! ViewController
                self.navigationController?.pushViewController(diaryView, animated: true)
            }
        }
        
        if (FBSDKAccessToken.current() != nil) {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    // ...
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let diaryView = storyboard.instantiateViewController(withIdentifier: "Dashboard") as! ViewController
                self.navigationController?.pushViewController(diaryView, animated: true)
            }
 
        } else {
            print("SOMETHING IS NOT WORKING")
        }
    }
   
}
