//
//  GardenCell.swift
//  SmartGarden
//
//  Created by Jason Shortino on 9/17/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class GardenCell: UITableViewCell {
    
    @IBOutlet weak var gardenNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
