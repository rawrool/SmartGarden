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
    
    //This function dictates what happens when the login button is tapped
    @IBAction func loginButtonTapped(_ sender: Any) {
        //try to log the user in
        attemptLogin( username:usernameText.text!, password:passwordText.text!)
        //Wait for the process to finish. There has to be a better way to do this
        sleep(1)
        
        //Check the loginStatus flag to see if it was successful
        let loggedIn = (UserDefaults.standard.object(forKey: "loginStatus")) as? Bool ?? false
        
        if(loggedIn){
            //Print the stored username and token
            print(UserDefaults.standard.object(forKey: "username") ?? "No Username")
            print(UserDefaults.standard.object(forKey: "token") ?? "No Token")
            //Clear textfields
            usernameText.text = ""
            passwordText.text = ""
            //Segue to the next screen
            performSegue(withIdentifier: "loggedIn", sender: sender)
        }
        else{
            //display login error alert
            loginErrorAlert()
        }//end else
    }//end loginButtonTapped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Next two lines rounds out the button to look more appealing
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
        
    }//end viewDidLoad
    
    override func viewDidAppear(_ animated: Bool) {
        if let username = UserDefaults.standard.object(forKey: "username"){
            print(username)
        } else {
            print("No username stored")
        }
        //Check if the user has a token and if so move past login screen
        //need to see if token is valid
        //if let token = UserDefaults.standard.object(forKey: "token"){
            //performSegue(withIdentifier: "loggedIn", sender: self)
        //}
    }//end viewDidAppear
    
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
    
    //Displays an alert to the user that the login failed
    func loginErrorAlert() {
        let alertController = UIAlertController(title: "Login Error", message:
            "Unable to login with that username/password.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }//end loginErrorAlert
    
    func attemptLogin(username:String, password:String){
        //store the username
        UserDefaults.standard.set(username, forKey: "username")
        //set the header for the http request
        let headers = [
            "content-type": "application/json"
        ]
        //set the parameters for the http request
        let parameters = [
            "email": username as Any, //"test@gmail.com"
            "password": password as Any //"test1234"
            ] as [String : Any]
        
        do{
            //Set up for the server request
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-18-218-39-84.us-east-2.compute.amazonaws.com/api/authenticate")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            //set the request type to a post request
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            let session = URLSession.shared
            
            //the nested function is where the data processing happens from the server's response
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                guard error == nil else {
                    //if the server returns an error we will print it and return
                    return
                }
                
                guard let data = data else {
                    //if there is nothing in the data variable we stop here
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        guard let success = json["success"] else { return }
                        
                        //print("Success Message:")
                        //print(success)
                        
                        //Set the loginStatus flag based on the success of the server request
                        if(success as? Bool ?? false){
                            UserDefaults.standard.set(true, forKey: "loginStatus")
                        } else { UserDefaults.standard.set(false, forKey: "loginStatus")}
                        
                        if success as? Bool ?? false{
                            //Ensure a token was returned
                            guard let token = json["token"] else { return }
                            
                            //let username = UserDefaults.standard.object(forKey: "username") as Any?
                            
                            //possibly switch to using the username as the key for the stored token
                            UserDefaults.standard.set(token, forKey: "token")
                        }
                    }
                } catch let error {
                    //if an error is thrown we print it here
                    print(error.localizedDescription)
                }
            })
            
            dataTask.resume()
        }
        catch{
            //if an error is thrown we print it here
            print("Caught error: ", error)
            return
        }
        return
    }
}
