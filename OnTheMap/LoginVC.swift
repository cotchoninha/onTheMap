//
//  LoginVC.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 04/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin

class LoginVC: UIViewController{
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        usernameTextField.text = "cotchoninha@yahoo.com.br"
        passwordTextField.text = "lulu1234"
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(usernameTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}".data(using: .utf8)
       
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            print("AQUI COMECA A IMPRIMIR O DATA!!!!")
            print(String(data: newData, encoding: .utf8)!)

            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as? [String:AnyObject]
            } catch{
                sendError("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let dictionarySession = parsedResult["session"] else{
                sendError("Cannot find keys 'session' in \(parsedResult)")
                return
            }
            if let sessionID = dictionarySession["id"] as? String{
                print("sessionID: \(sessionID)")
                DispatchQueue.main.async {
                 (UIApplication.shared.delegate as! AppDelegate).sessionID = sessionID
                }
            }else{
                print("could not find a SessionID.")
            }
        }
        
        task.resume()
        
    }
    
    @IBAction func SignInButton(_ sender: Any) {
        
        let udacityWebSite = URL(string: "https://www.udacity.com/account/auth#!/signup")!
        UIApplication.shared.open(udacityWebSite, options: [:], completionHandler: nil)
        
    }
    
    
}


