//
//  GardenCell.swift
//  SmartGarden
//
//  Created by Jason Shortino on 9/17/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

//This class is used to customize the cells in the garden selection table
class GardenCell: UITableViewCell {
    
    //variable to display the garden name
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
