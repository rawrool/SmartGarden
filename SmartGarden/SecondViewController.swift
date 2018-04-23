//
//  SecondViewController.swift
//  SmartGarden
//
//  Created by Jason Shortino on 2/28/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import UIKit

struct GardenReading {
    var temp = 0
    var hum = 0
    var date = Date.init()
}

class SecondViewController: UIViewController, UITableViewDataSource {
    var readings = [GardenReading]()
    let temps = [60,61,62,63,64,65,66,67,68,69]
    let hums = [30,35,40,45,50,55,60,65,70,75]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0..<10{
            readings.append(GardenReading(temp:temps[i], hum:hums[i], date:Date.init()))
        }
        print(readings.count)
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell") as! MyCell
        
        cell.temp_Label.text = String(readings[indexPath.row].temp)
        cell.hum_Label.text = String(readings[indexPath.row].hum)
        var date = readings[indexPath.row].date.description
        date.removeLast(6)
        cell.date_Label.text = date
        
        return cell
    }
}
