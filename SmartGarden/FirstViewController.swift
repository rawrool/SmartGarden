//  FirstViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 2/28/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

//automatically created import
import UIKit

//  This view controller is for the Garden Scene
class FirstViewController: UIViewController {
    //variable to manipulate the garden title label
    @IBOutlet weak var gardenTitleLabel: UILabel!
    
    //variable to manipulate the temperature label
    @IBOutlet weak var tempLabel: UILabel!
    
    //variable to manipulate the humidity label
    @IBOutlet weak var humidityLabel: UILabel!
    
    //variable to manipulate the sprinkler label
    @IBOutlet weak var sprinklerLabel: UILabel!
    
    //variable linked to the "Garden Details"
    @IBOutlet weak var detailsButton: UIButton!
    
    //Look up SwiftyGif or something to display a GIF File
    override func viewDidLoad() {
        super.viewDidLoad()
        //Next two lines rounds out the button to look more appealing
        detailsButton.layer.cornerRadius = 10
        detailsButton.clipsToBounds = true
    }
    
    @IBAction func unwindSegue(_ sender : UIStoryboard){
        
    }


    //automatically created function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

