//
//  tableViewController.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 07/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class ListOfStudentsViewController: UITableViewController {
    
    var allStudents = [Student]()
    var parseAPIClient = ParseAPIClient()
    var udacityAPIClient = UdacityAPIClient()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parseAPIClient.getStudentsLocations {(success, studentsArray, error) in
            if success{
                performUIUpdatesOnMain {
                    self.allStudents = studentsArray!
                    self.tableView.reloadData()
                }
            }else{
                //tratar o erro
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        //checar se está logado com a udacity ou facebook e fazer logoff por um destes
        udacityAPIClient.logoutUser { (success, error) in
            if success{
                performUIUpdatesOnMain {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
                    self.present(controller, animated: true, completion: nil)
                }
            }else{
                //tratar o erro
            }
        }
    }
//falta testar se funciona....
    @IBAction func refreshButton(_ sender: Any) {
        parseAPIClient.getStudentsLocations {(success, studentsArray, error) in
            if success{
                performUIUpdatesOnMain {
                    self.allStudents = studentsArray!
                    self.tableView.reloadData()
                }
            }else{
                //tratar o erro
            }
        }
    }


    @IBAction func addButton(_ sender: Any) {
        
    }
    
}
