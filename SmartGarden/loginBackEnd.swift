//
//  loginBackEnd.swift
//  SmartGarden
//
//  Created by Jason Shortino on 9/24/18.
//  Copyright © 2018 Jason Shortino. All rights reserved.
//

import Foundation

struct LoginResponse:Decodable{
    let success:String
    let message:String
    let token:String
}

func attemptLogin(username:String, password:String) -> Bool{
    
    var successful = false
    let headers = [
        "content-type": "application/json",
        "cache-control": "no-cache",
        "postman-token": "d27aaceb-a447-5a52-2aa8-42e7e2ac3424"
    ]
    
    let parameters = [
        "email": username as Any,
        "password": password as Any
        ] as [String : Any]
    
    do{
        let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        let request = NSMutableURLRequest(url: NSURL(string: "http://ec2-18-191-18-131.us-east-2.compute.amazonaws.com/api/authenticate")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
                
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
                successful = true
            }
        })
        dataTask.resume()
    }
    catch{
        print("Caught error: ", error)
        return false
    }
    
    return successful
}

func setToken(serverResponse:HTTPURLResponse){
    
    /*guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: serverResponse as Data)
     else { print("Error decoding data into LoginResponse")
     return}*/
    
}
