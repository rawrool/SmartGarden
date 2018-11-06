//
//  NewGardenViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 10/10/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class NewGardenViewController: UIViewController {
    //Gets the new garden name from the user
    @IBOutlet weak var gardenName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //Cancels the creation of the new garden and goes back to previous view
    @IBAction func cancelCreation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //Try to create a garden
    @IBAction func createGarden(_ sender: Any) {
        //check to ensure the user entered something in the textfield
        if(gardenName.text != nil){
            //call the function to talk to the server
            attemptGarden(name: gardenName.text ?? "")
            //wait for the function to finish.
            sleep(1)
            
            //check the flag to see if the garden was created
            let created = UserDefaults.standard.object(forKey: "gardenCreated") as? Bool ?? false
            if(!created){
                //If it was not created, display an alert to the user
                ErrorAlert(text: "The garden could not be created at this time. Please try again later.")
            }
            else{
                //if it was created, return to the garden selection screen
                dismiss(animated: true, completion: nil)
            }
        }
        else{
            //Alert the user they must enter something
            ErrorAlert(text: "Must enter a name!")
        }
    }//end createGarden
    
    //displays an alert on screen with the text passed in
    func ErrorAlert(text: String) {
        let alertController = UIAlertController(title: "Error", message:
            text, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }//end loginErrorAlert
    
    //Send a request to the server to create a garden for the user
    func attemptGarden(name: String){
        //set to false to begin with just in case
        UserDefaults.standard.set(false, forKey: "gardenCreated")
        //set the header for the http request
        let headers = [
            "content-type": "application/json"
        ]
        //set the parameters for the http request
        let parameters = [
            "email": UserDefaults.standard.object(forKey: "username") ?? "no username",
            "token": UserDefaults.standard.object(forKey: "token") ?? "no token",
            "garden": name
            ] as [String : Any]
        do{
            //set up for the server request
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-18-218-39-84.us-east-2.compute.amazonaws.com/api/gardens")! as URL,
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
                    //if the http request returns an error then stop here
                    return
                }
                guard let data = data else {
                    //if there is nothing in the data variable we stop here
                    return
                }
                //print(String(decoding: data, as: UTF8.self))
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        //Try to parse out the message
                        guard let message = json["message"] else { return }
                        
                        //Check whether the server says the garden was created and set our flag accordingly
                        if(message as? String ?? "" == "Garden Created!"){
                            UserDefaults.standard.set(true, forKey: "gardenCreated")
                        }
                        else{
                            UserDefaults.standard.set(false, forKey: "gardenCreated")
                        }
                        
                    }
                } catch let error {
                    //if an error is thrown we print it here
                    print(error.localizedDescription)
                    
                    UserDefaults.standard.set(false, forKey: "gardenCreated")
                    return
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
