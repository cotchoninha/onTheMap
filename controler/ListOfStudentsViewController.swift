//
//  tableViewController.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 07/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class ListOfStudentsViewController: UITableViewController {
    
    var allStudents = [Student]()
    var parseAPIClient = ParseAPIClient()
    var udacityAPIClient = UdacityAPIClient()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parseAPIClient.getStudentsLocations {(success, studentsArray, error) in
            performUIUpdatesOnMain {
                if success{
                    self.allStudents = studentsArray!
                    self.tableView.reloadData()
                    
                }else{
                    UserAlertManager.showAlert(title: "Empty list.", message: "Sorry, we couldn't obtain the other students locations.", buttonMessage: "Try logging in again.", viewController: self)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStudents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! LocationTableViewCell
        let student = self.allStudents[indexPath.row]
        cell.studentName.text = student.firstName
        cell.studentLink.text = student.mediaURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentRow = self.allStudents[indexPath.row]
        guard let studentLink = studentRow.mediaURL else{
            print("there's no link for this student")
            return
        }
        if let link = URL(string: "\(studentLink)"){
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        }else{
            print("could not open the link for this student")
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        udacityAPIClient.logoutUser { (success, error) in
            performUIUpdatesOnMain {
                if success{
                    FBSDKLoginManager().logOut()
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
                    self.present(controller, animated: true, completion: nil)
                    
                }else{
                    switch error{
                    case LoginRequestERROR.connectionFailed?:
                        UserAlertManager.showAlert(title: "No connection", message: "There's no network connection. Please, try again.", buttonMessage: "Try again.", viewController: self)
                    case LoginRequestERROR.invalidUserImput?:
                        UserAlertManager.showAlert(title: "Logout failed.", message: "We couldn't logout from your account. Try again.", buttonMessage: "Try again.", viewController: self)
                    case LoginRequestERROR.noDataReturned?:
                        UserAlertManager.showAlert(title: "Logout failed.", message: "We couldn't logout from your account. Try again.", buttonMessage: "Try again.", viewController: self)
                    default:
                        print("an error has occured")
                        UserAlertManager.showAlert(title: "Logout failed.", message: "We couldn't logout from your account. Try again.", buttonMessage: "Try again.", viewController: self)
                    }
                }
            }
        }
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        parseAPIClient.getStudentsLocations {(success, studentsArray, error) in
            performUIUpdatesOnMain {
                if success{
                    self.allStudents = studentsArray!
                    self.tableView.reloadData()
                    
                }else{
                    UserAlertManager.showAlert(title: "Empty list.", message: "Sorry, we couldn't obtain the other students locations.", buttonMessage: "Try logging in again.", viewController: self)
                }
            }
        }
    }
    
    
    @IBAction func addButton(_ sender: Any) {
        
    }
    
}
