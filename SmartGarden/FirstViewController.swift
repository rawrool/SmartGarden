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
    
    //Navigation bar with the title and done button
    @IBOutlet weak var titleBar: UINavigationItem!
    
    //Look up SwiftyGif or something to display a GIF File
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gardenName = UserDefaults.standard.object(forKey: "garden") as? String ?? "Error"
        gardenTitleLabel.text = gardenName
        titleBar.title = gardenName
    }
    
    //This function is called when the done button is pressed
    @IBAction func donePressed(_ sender: Any) {
        //dismisses the current view and returns to the previous view
        dismiss(animated: true, completion: nil)
    }


    //automatically created function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

