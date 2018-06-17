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
import FBSDKLoginKit
import FacebookCore

class LoginVC: UIViewController, LoginButtonDelegate{
    
    let udacityClient = UdacityAPIClient()
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logOut")
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    func loginButtonDidCompleteLogin(_ loginButton:LoginButton,result:LoginResult){
        switch result {
        case .failed(let error):
            print(error)
            UserAlertManager.showAlert(title: "Sorry! We couldn't access your account.", message: "Check your information again.", buttonMessage: "Try again.", viewController: self)
        case .cancelled:
            print("Cancelled")
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("Logged In")
            var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
            
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken);\"}}".data(using: .utf8)
            request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken.authenticationToken)\"}}".data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                func sendError(_ error: String) {
                    print(error)
                }
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    sendError("There was an error with your request: \(error!)")
                    UserAlertManager.showAlert(title: "No internet connection.", message: "Your connection seems to be out! Try again later.", buttonMessage: "Try again.", viewController: self)
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    UserAlertManager.showAlert(title: "Sorry! We couldn't access your account.", message: "Check your information again.", buttonMessage: "Try again.", viewController: self)
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
                
                guard let dictionarySession = parsedResult["session"], let dictionaryAccount = parsedResult["account"] else{
                    sendError("Cannot find keys 'session' in \(parsedResult)")
                    return
                }
                if let sessionID = dictionarySession["id"] as? String, let keyAccount = dictionaryAccount["key"] as? String{
                    print("MARCELA - sessionID: \(sessionID) and accountKey: \(keyAccount)")
                    performUIUpdatesOnMain {
                        (UIApplication.shared.delegate as! AppDelegate).sessionID = sessionID
                        (UIApplication.shared.delegate as! AppDelegate).keyAccount = keyAccount
                        self.completeLogin()
                    }
                    
                }else{
                    print("could not find a SessionID.")
                }
            }
            task.resume()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.delegate = self
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
    
    func completeLogin() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "UsersTabBarController") as! UITabBarController
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        usernameTextField.text = "cotchoninha@yahoo.com.br"
        passwordTextField.text = "lulu1234"
        
        //check if username and password are not empty
        if  usernameTextField.text == "" || usernameTextField.text == nil{
            UserAlertManager.showAlert(title: "Invalid username", message: "Please, type a valid username.", buttonMessage: "Try again.", viewController: self)
            return
        }
        if passwordTextField.text == "" || passwordTextField.text == nil{
            UserAlertManager.showAlert(title: "Invalid password", message: "Please, type a valid password.", buttonMessage: "Try again.", viewController: self)
            return
        }
        
        //call a function that will make the login request passing a completion handler for the response
        udacityClient.userLoginRequest(username: usernameTextField.text!, password: passwordTextField.text!) { (success, sessionID, keyAccount, error) in
            if success{
                //caso login tenha dado certo
                performUIUpdatesOnMain {
                    print("MARCELA - sessionID: \(sessionID) and accountKey: \(keyAccount)")
                    (UIApplication.shared.delegate as! AppDelegate).sessionID = sessionID
                    (UIApplication.shared.delegate as! AppDelegate).keyAccount = keyAccount
                    self.completeLogin()
                }
            }else{
                //caso login nao tenha dado certo
                UserAlertManager.showAlert(title: "Login failed.", message: "We couldn't access your account. Try again.", buttonMessage: "Try again.", viewController: self)
                
                //TODO: Handle different type of errors later
//                UserAlertManager.showAlert(title: "No internet connection.", message: "Your connection seems to be out! Try again later.", buttonMessage: "Try again.", viewController: self)
//                UserAlertManager.showAlert(title: "Sorry! We couldn't access your account.", message: "Check your information again.", buttonMessage: "Try again.", viewController: self)
            }
            
        }
    }
    
    @IBAction func SignInButton(_ sender: Any) {
        
        let udacityWebSite = URL(string: "https://www.udacity.com/account/auth#!/signup")!
        UIApplication.shared.open(udacityWebSite, options: [:], completionHandler: nil)
    }
    
}


