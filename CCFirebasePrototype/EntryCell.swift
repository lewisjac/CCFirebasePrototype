//
//  EntryCell.swift
//  CCFirebasePrototype
//
//  Created by Jack Simmons on 9/21/18.
//  Copyright © 2018 Jack Simmons. All rights reserved.
//

import UIKit

class EntryCell: UITableViewCell {
    
    @IBOutlet var calories: UILabel!
    @IBOutlet var desc: UILabel!
    @IBOutlet var time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
