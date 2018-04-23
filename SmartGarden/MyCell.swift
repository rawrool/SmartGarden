//
//  MyCell.swift
//  SmartGarden
//
//  Created by Jason Shortino on 3/3/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {
    @IBOutlet weak var temp_Label: UILabel!
    @IBOutlet weak var hum_Label: UILabel!
    @IBOutlet weak var date_Label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
