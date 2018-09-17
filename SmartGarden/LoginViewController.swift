//
//  LoginViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 9/16/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        //place user login verification here
        
        if (usernameText.text == "hi"){
            //this line will segue to the garden select screen
            //verify user login before this
            performSegue(withIdentifier: "loggedIn", sender: sender)
        }
        else {
            showAlert();
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Next two lines rounds out the button to look more appealing
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function makes the keyboard disappear when anywhere but the keyboard is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func showAlert() {
        let alertController = UIAlertController(title: "Login Error", message:
            "Unable to login with that username/password.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
