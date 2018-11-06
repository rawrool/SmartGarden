//
//  MyCell.swift
//  SmartGarden
//
//  Created by Jason Shortino on 3/3/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

//automatically created with the file
import UIKit

//class to control the custom cell we created in the storyboard in the secondviewcontroller
class MyCell: UITableViewCell {
    
    //variable to manipulate the temperature label in the cell
    @IBOutlet weak var temp_Label: UILabel!
    //variable to manipulate the humidity label in the cell
    @IBOutlet weak var hum_Label: UILabel!
    //variable to manipulate the date label in the cell
    @IBOutlet weak var date_Label: UILabel!
    
    //automatically created with the file
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //code for when the cell is selected/tapped on
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}//end class MyCell
