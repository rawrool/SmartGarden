//
//  NewGardenViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 10/10/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class NewGardenViewController: UIViewController {
    @IBOutlet weak var gardenName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelCreation(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createGarden(_ sender: Any) {
        if(gardenName.text != nil){
            attemptGarden(name: gardenName.text ?? "")
            sleep(1)
            let created = UserDefaults.standard.object(forKey: "gardenCreated") as? Bool ?? false
            if(!created){
                ErrorAlert(text: "Something went wrong and the garden could not be created")
            }
            else{
                dismiss(animated: true, completion: nil)
            }
        }
        else{
            ErrorAlert(text: "Must enter a name!")
        }
    }//end createGarden
    
    func ErrorAlert(text: String) {
        let alertController = UIAlertController(title: "Error", message:
            text, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }//end loginErrorAlert
    
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
            "gardenName": name
            ] as [String : Any]
        do{
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-18-191-18-131.us-east-2.compute.amazonaws.com/api/gardens")! as URL,
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
                        print("About to set success variable")
                        guard let message = json["message"] else { return }
                        
                        //print(success as? String ?? "Nothing to convert setting to false")
                        
                        if(message as? String ?? "" == "Garden Created!"){
                            UserDefaults.standard.set(true, forKey: "gardenCreated")
                        }
                        
                    }
                } catch let error {
                    print("there was an error")
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
