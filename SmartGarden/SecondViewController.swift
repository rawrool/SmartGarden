//
//  SecondViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 2/28/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

//automatically created with file
import UIKit

//structure to hold readings to display in the table
struct GardenReading {
    var temp = 0
    var hum = 0
    var date = Date.init()
}

//view controller for the "Search" tab
class SecondViewController: UIViewController, UITableViewDataSource {
    //array to hold readings
    var readings = [GardenReading]()
    //array of temperatures
    let temps = [60,61,62,63,64,65,66,67,68,69]
    //array of humidity readings
    let hums = [30,35,40,45,50,55,60,65,70,75]
    
    //variable to manipulate and get data from the start date label
    @IBOutlet weak var startDateLabel: UITextField!
    //variable to manipulate and get data from the end date label
    @IBOutlet weak var endDateLabel: UITextField!
    
    //variable to manipulate the table
    @IBOutlet weak var tableView: UITableView!
    
    //runs as soon as the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        //loops through and fills the structure array with readings
        for i in 0..<10{
            readings.append(GardenReading(temp:temps[i], hum:hums[i], date:Date.init()))
        }
        //prints how many elements are in the readings array
        print(readings.count)
        tableView.dataSource = self
    }
    
    //automatically created with the file
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //required for table, breaks the table into sections based on return value
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //required for table, creates the amount of cells that will be in each section of the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readings.count
    }
    
    //can manipulate the custom cell created in the storyboard with custom data in this function
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell is equal to the custom cell we created in the storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell") as! MyCell
        
        //set the temperature label in the cell
        cell.temp_Label.text = String(readings[indexPath.row].temp)
        //set the humidity label in the cell
        cell.hum_Label.text = String(readings[indexPath.row].hum)
        //get the date from our array
        var date = readings[indexPath.row].date.description
        //remove the last 6 characters
        date.removeLast(6)
        //set the date label in the cell
        cell.date_Label.text = date
        
        //return the cell we created to be displayed in the table
        return cell
    }
}//end class SecondViewController
