//
//  TableVC.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/20/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class TableVC: UITableViewController {
    var ref: DatabaseReference!
    var userEntries = [UserEntry]()
    let userID = Auth.auth().currentUser?.uid
    

   
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        ref = Database.database().reference().child(userID!) // change .child to reference user's login information.
        startObservingBD()
    }
    

    func startObservingBD() {
        ref.queryLimited(toLast: 75).observe(.value, with: {(snapshot: DataSnapshot) in
            var newEntries = [UserEntry]()
            
            for entry in snapshot.children {
                let entryObject = UserEntry(snapshot: entry as! DataSnapshot)
                
                newEntries.append(entryObject)
            }
            
            self.userEntries = newEntries.reversed()
            print(self.userEntries)
            self.tableView.reloadData()
        }, withCancel: {(error: Error) in
            print(error.localizedDescription)
        })
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEntries.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EntryCell
        let entry = userEntries[indexPath.row]
        cell.calories?.text = entry.calories
        cell.desc?.text = entry.description
        cell.time?.text = entry.dateTime
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let entry = userEntries[indexPath.row]
            entry.itemRef?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = userEntries[indexPath.row] // would this pass an actual reference
        EditVC(ref: entry)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "EditVC") as! EditVC
        self.navigationController?.pushViewController(nextView, animated: true)
       
    }
    

}
