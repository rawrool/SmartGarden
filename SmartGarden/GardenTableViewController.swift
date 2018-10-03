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
    var gardens = ["Cabbage", "Carrots", "Basil", "Tomatoes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGardens()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        cell.gardenNameLabel.text = gardens[indexPath.row]

        return cell
    }
    
    func getGardens() -> Bool{
        
        //set the header for the http request
        let headers = [
            "content-type": "application/json"
        ]
        //set the parameters for the http request
        let parameters = [
            "email": UserDefaults.standard.object(forKey: "username") ?? "No Username",
            "token": UserDefaults.standard.object(forKey: "token") ?? "No Token"
            ] as [String : Any]
        
        do{
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-18-191-18-131.us-east-2.compute.amazonaws.com/api/gardens")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
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
                    print("Data from get request")
                    print(data)
                    print("Response from get request")
                    print(response as Any)
                    print("Error from get request")
                    print(error as Any)
                    //create json object from data
                    /*if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        guard let success = json["success"] else { return }
                        print("Success Message:")
                        print(success)
                        if success as? Bool ?? false{
                            guard let token = json["token"] else { return }
                            let username = UserDefaults.standard.object(forKey: "username") as Any?
                            print("In dataTask Username: ")
                            print(username!)
                            print(token)
                            //possibly switch to using the username as the key for the stored token
                            UserDefaults.standard.set(token, forKey: "token")
                        }
                    }*/
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
