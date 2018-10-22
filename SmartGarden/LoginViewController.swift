//
//  LoginViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 9/16/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

struct LoginResponse:Decodable{
    let success:String
    let message:String
    let token:String
    
    init(json: [String: Any]){
        success = json["success"] as? String ?? ""
        message = json["message"] as? String ?? ""
        token = json["token"] as? String ?? ""
    }
}

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
       
        attemptLogin( username:usernameText.text!, password:passwordText.text!)
        sleep(1)
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
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-18-218-39-84.us-east-2.compute.amazonaws.com/api/authenticate")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            let session = URLSession.shared
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                guard error == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        guard let success = json["success"] else { return }
                        print("Success Message:")
                        print(success)
                        
                        if(success as? Bool ?? false){
                            UserDefaults.standard.set(true, forKey: "loginStatus")
                        } else { UserDefaults.standard.set(false, forKey: "loginStatus")}
                        
                        if success as? Bool ?? false{
                            guard let token = json["token"] else { return }
                            let username = UserDefaults.standard.object(forKey: "username") as Any?
                            
                            //possibly switch to using the username as the key for the stored token
                            UserDefaults.standard.set(token, forKey: "token")
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            
            dataTask.resume()
        }
        catch{
            print("Caught error: ", error)
            return
        }
        return
    }
}
