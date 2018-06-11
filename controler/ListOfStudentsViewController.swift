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
    
    func checkForErrors(data: Data?, response: URLResponse?, error: Error?){
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
    }
    
    func getStudendLocation(){
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            self.checkForErrors(data: data, response: response, error: error)
            
            if let studentsList = self.parseDataWithCodable(data: data!){
                self.allStudents = studentsList
                print(studentsList)
            }
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    func parseDataWithCodable(data: Data) -> [Student]? {
        
        let jsonDecoder = JSONDecoder()
        do{
            let studentsResult = try jsonDecoder.decode(StudentResult.self, from: data)
            return studentsResult.results
        } catch{
            print("Could not parse the data as JSON: '\(data)'")
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudendLocation()
        tableView.reloadData()
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
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            self.checkForErrors(data: data, response: response, error: error)
            let range = Range(5..<data!.count)
            _ = data?.subdata(in: range) /* subset response data! */
            //should I use dismiss instead of calling the LoginVC again?
            performUIUpdatesOnMain {
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as UIViewController
                self.present(controller, animated: true, completion: nil)
            }
            
        }
        task.resume()

    }
//falta testar se funciona....
    @IBAction func refreshButton(_ sender: Any) {
        performUIUpdatesOnMain {
            print("refreshiando")
            self.getStudendLocation()
        }
    }


    @IBAction func addButton(_ sender: Any) {
        
    }
    
}
