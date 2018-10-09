//
//  GardenTableViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 9/16/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

class GardenTableViewController: UITableViewController {
    //sample garden names
    var gardens = [["name": "A", "_id": "3asdfasdfg"], ["name": "B", "_id": "3asdgasdfg"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gardens.removeAll()
        getGardens()
        //FIND A WAY TO WAIT FOR THE HTTP REQUEST TO FINISH BEFORE SHOWING SCREEN, OR REFRESHING TABLE AFTER THE REQUEST FINISHES
        sleep(1)
        print("Got Gardens")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Preparing for segue after garden select")
        print(segue.identifier as Any)
        if  segue.identifier == "gardenSelected" {
            if let destination = segue.destination as? FirstViewController {
            let gardenIndex = tableView.indexPathForSelectedRow?.row
            print("Setting the gardenName in the next view controller:")
            print(gardens[gardenIndex ?? 0]["name"] ?? "Error no garden names")
            destination.gardenName = gardens[gardenIndex!]["name"] ?? "Error no garden names"
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return gardens.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gardenCell", for: indexPath) as! GardenCell

        cell.gardenNameLabel.text = gardens[indexPath.row]["name"]
        print(gardens[indexPath.row]["name"] as Any)
        return cell
    }
    
    func getGardens() -> Bool{
        
        //set the header for the http request
        let headers = [
            "content-type": "application/json",
            "email": UserDefaults.standard.object(forKey: "username") as? String ?? "No Username",
            "x-access-token": UserDefaults.standard.object(forKey: "token") as? String ?? "No Token"
        ]
        
        do{
            //let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-18-191-18-131.us-east-2.compute.amazonaws.com/api/gardens")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            //request.httpBody = postData as Data
            
            let session = URLSession.shared
            
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                guard error == nil else {
                    print("error in get")
                    print(error as Any)
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print("Json Object Returned: ")
                        print(json)
                        for var x in json {
                            x.removeValue( forKey: "plants")
                            self.gardens.append(x as? [String : String] ?? ["Fail":"Fail"])
                        }
                        
                        print(self.gardens)
                    } else { print("Could not serialize the data into json")}
                } catch let error {
                    print(error.localizedDescription)
                }
            })
            
            dataTask.resume()
        }
        catch{
            print("Caught error: ", error)
            return false
        }
        return true
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
