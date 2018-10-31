//
//  GardenTableViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 9/16/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class GardenTableViewController: UITableViewController {
    // sample garden names
    var gardens = [["name": "A", "_id": "3asdfasdfg"], ["name": "B", "_id": "3asdgasdfg"]]
    
    // this function runs everytime the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The next 3 lines give the table pull down to refresh functionality
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(getGardens), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Clear the placeholder gardens
        gardens.removeAll()
        
        // Get the gardens from the server
        getGardens()
        
        // Wait for the the server request to finish
        sleep(1)
        
        // Reload the table data
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Navigate to the next screen and store the selected garden so the next view can use it
        if let gardenIndex = tableView.indexPathForSelectedRow?.row {
            UserDefaults.standard.set(gardens[gardenIndex]["name"], forKey: "garden")
        }
    }
    
    // Logs out the user and clears their info from storage
    @IBAction func logOut(_ sender: Any) {
        //Clear the username
        UserDefaults.standard.set("", forKey: "username")
        //clear the token
        UserDefaults.standard.set("", forKey: "token")
        //clear the loginStatus flag
        UserDefaults.standard.set(false, forKey: "loginStatus")
        //Navigate back to login screen
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #return the number of rows
        return gardens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Set up cell variable using our custom cell class Gardencell
        let cell = tableView.dequeueReusableCell(withIdentifier: "gardenCell", for: indexPath) as! GardenCell
        
        //Set the label in the cell to garden at the index of the cell in the table
        cell.gardenNameLabel.text = gardens[indexPath.row]["name"]
        
        //print(gardens[indexPath.row]["name"] as Any)
        return cell
    }
    
    //This function gets the user's gardens from the server
    @objc func getGardens(){
        
        //set the header for the http request
        let headers = [
            "content-type": "application/json",
            "email": UserDefaults.standard.object(forKey: "username") as? String ?? "No Username",
            "x-access-token": UserDefaults.standard.object(forKey: "token") as? String ?? "No Token"
        ]
        
        do{
            //let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-18-218-39-84.us-east-2.compute.amazonaws.com/api/gardens")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            //set the request to a get request
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            //request.httpBody = postData as Data
            
            let session = URLSession.shared
            
            //the nested function is where the data processing happens from the server's response
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                guard error == nil else {
                    //if the server returns an error we will print it and return
                    print("error in get")
                    print(error as Any)
                    return
                }
                
                guard let data = data else {
                    //if there is nothing in the data variable we stop here
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        //print("Json Object Returned: ")
                        //print(json)
                        
                        //each x is a garden from json
                        for var x in json {
                            //remove the variable so we can add to our gardens variable without error
                            x.removeValue( forKey: "plants")
                            //add the garden to our gardens variable
                            self.gardens.append(x as? [String : String] ?? ["Fail":"Fail"])
                        }
                        
                        //print(self.gardens)
                    } else { print("Could not serialize the data into json")}
                    
                } catch let error {
                    //if an error is thrown we print it here
                    print(error.localizedDescription)
                }
            })
            
            dataTask.resume()
        }
        return
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
