//
//  FirstViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 2/28/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var details: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    
    //Look up SwiftyGif or something to display a GIF File
    override func viewDidLoad() {
        super.viewDidLoad()
        details.layer.cornerRadius = 10
        details.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

