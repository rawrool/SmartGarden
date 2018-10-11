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
    var gardenName = String()
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
    
    //Navigation bar with the title and done button
    @IBOutlet weak var titleBar: UINavigationItem!
    
    //Look up SwiftyGif or something to display a GIF File
    override func viewDidLoad() {
        super.viewDidLoad()
        //Next two lines rounds out the button to look more appealing
        detailsButton.layer.cornerRadius = 10
        detailsButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gardenName = UserDefaults.standard.object(forKey: "garden") as? String ?? "Error"
        gardenTitleLabel.text = gardenName
        titleBar.title = gardenName
    }
    
    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func unwindSegue(_ sender : UIStoryboard){
        
    }


    //automatically created function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

