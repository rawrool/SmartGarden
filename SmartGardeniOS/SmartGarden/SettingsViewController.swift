//
//  SettingsViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 4/29/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    //variable to manipulate the "Select the data you want recorded" button
    @IBOutlet weak var dataButton: UIButton!
    //variable to manipulate the "Set a water schedule" button
    @IBOutlet weak var setWaterButton: UIButton!
    //variable to manipulate the "Create a water schedule" button
    @IBOutlet weak var createWaterButton: UIButton!
    //variable to manipulate the "changing the background" button
    @IBOutlet weak var changeBackground: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    @IBAction func unwindSegue(_sender : UIStoryboardSegue){
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
