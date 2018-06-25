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
    
    
    //MARK: Properties
    let udacityClient = UdacityAPIClient()
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    //TODO:
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logOut")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        usernameTextField.text = "cotchoninha@yahoo.com.br"
        passwordTextField.text = "lulu1234"
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.delegate = self
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        
    }
    
    //MARK: LOGIN WITH FACEBOOK
    func loginButtonDidCompleteLogin(_ loginButton:LoginButton,result:LoginResult){
        switch result {
        case .failed(let error):
            print(error)
            UserAlertManager.showAlert(title: "Sorry! We couldn't access your account.", message: "Check your information again.", buttonMessage: "Try again.", viewController: self)
        case .cancelled:
            print("Cancelled")
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("Logged In")
            udacityClient.userLoginRequestWithFacebook(authenticationToken: accessToken.authenticationToken) { (success, sessionID, keyAccount, error) in
                performUIUpdatesOnMain {
                    if success{
                        //caso login tenha dado certo
                        print("MARCELA - sessionID: \(sessionID) and accountKey: \(keyAccount)")
                        (UIApplication.shared.delegate as! AppDelegate).sessionID = sessionID
                        (UIApplication.shared.delegate as! AppDelegate).keyAccount = keyAccount
                        self.completeLogin()
                        
                    }else{
                        switch error{
                        case LoginRequestERROR.connectionFailed?:
                            UserAlertManager.showAlert(title: "No connection", message: "There's no network connection. Please, try again.", buttonMessage: "Try again.", viewController: self)
                        case LoginRequestERROR.invalidUserImput?:
                            UserAlertManager.showAlert(title: "Login failed.", message: "We couldn't access your account. Try again.", buttonMessage: "Try again.", viewController: self)
                        case LoginRequestERROR.noDataReturned?:
                            UserAlertManager.showAlert(title: "Login failed.", message: "We couldn't access your account. Try again.", buttonMessage: "Try again.", viewController: self)
                        default:
                            print("an error has occured")
                            UserAlertManager.showAlert(title: "Login failed.", message: "We couldn't access your account. Try again.", buttonMessage: "Try again.", viewController: self)
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    //MARK: COMPLETE LOGIN INSTANTIATE TAB VC
    func completeLogin() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "UsersTabBarController") as! UITabBarController
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: LOGIN WITH UDACITY USER
    @IBAction func loginButton(_ sender: Any) {
        //start activity indicator
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        loginButtonOutlet.isEnabled = false
        
        //check if username and password are not empty
        if  usernameTextField.text == "" || usernameTextField.text == nil{
            UserAlertManager.showAlert(title: "Invalid username", message: "Please, type a valid username.", buttonMessage: "Try again.", viewController: self)
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            return
        }
        if passwordTextField.text == "" || passwordTextField.text == nil{
            UserAlertManager.showAlert(title: "Invalid password", message: "Please, type a valid password.", buttonMessage: "Try again.", viewController: self)
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            return
        }
        
        //call a function that will make the login request passing a completion handler for the response
        udacityClient.userLoginRequest(username: usernameTextField.text!, password: passwordTextField.text!) { (success, sessionID, keyAccount, error) in
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                if success{
                    //caso login tenha dado certo
                    print("MARCELA - sessionID: \(sessionID) and accountKey: \(keyAccount)")
                    (UIApplication.shared.delegate as! AppDelegate).sessionID = sessionID
                    (UIApplication.shared.delegate as! AppDelegate).keyAccount = keyAccount
                    self.completeLogin()
                }else {
                    switch error{
                    case LoginRequestERROR.connectionFailed?:
                        UserAlertManager.showAlert(title: "No connection", message: "There's no network connection. Please, try again.", buttonMessage: "Try again.", viewController: self)
                    case LoginRequestERROR.invalidUserImput?:
                        UserAlertManager.showAlert(title: "Login failed.", message: "We couldn't access your account. Try again.", buttonMessage: "Try again.", viewController: self)
                    case LoginRequestERROR.noDataReturned?:
                        UserAlertManager.showAlert(title: "Login failed.", message: "We couldn't access your account. Try again.", buttonMessage: "Try again.", viewController: self)
                    default:
                        print("an error has occured")
                        UserAlertManager.showAlert(title: "Login failed.", message: "We couldn't access your account. Try again.", buttonMessage: "Try again.", viewController: self)
                    }
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
        }
    }
    
    //MARK: SIGN IN WITH UDACITY
    @IBAction func SignInButton(_ sender: Any) {
        
        let udacityWebSite = URL(string: "https://www.udacity.com/account/auth#!/signup")!
        UIApplication.shared.open(udacityWebSite, options: [:], completionHandler: nil)
    }
    
}

