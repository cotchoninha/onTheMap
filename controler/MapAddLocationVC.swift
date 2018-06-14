//
//  AddMapVC.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 13/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import MapKit

class AddMapViewController: UIViewController, MKMapViewDelegate{
    
    var locationAnnotation: MKPointAnnotation?
    var locationString: String?
    var userLink: String?
    var user: User?
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        getUserInfo()
        self.mapView.delegate = self
        if let annotationLocation = self.locationAnnotation{
            self.mapView.addAnnotation(annotationLocation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    //TODO adaptar checkForErrors em todas as viewControllers
    func checkForErrors(data: Data?, response: URLResponse?, error: Error?) -> Bool{
        //retornar true ou false pra tratar o data se for nil
        func sendError(_ error: String) {
            print(error)
        }
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            sendError("There was an error with your request: \(error!)")
            return false
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            sendError("Your request returned a status code other than 2xx!")
            return false
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            sendError("No data was returned by the request!")
            return false
        }
        
        return true
    }
    
    func parseDataWithCodable<T: Decodable>(_ type: T.Type, data: Data) -> T? {
        
        let jsonDecoder = JSONDecoder()
        do{
            return try jsonDecoder.decode(type, from: data)
        } catch{
            print("Could not parse the data as JSON: '\(data)'")
            return nil
        }
    }
    
    func getUserInfo(){
        guard let accountKey = appDelegate.keyAccount else{
            print("MARCELA - there was no accountKey")
            return
        }
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(accountKey)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            let checkErrorResult = self.checkForErrors(data: data, response: response, error: error)
            if checkErrorResult{
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                print("MARCELA - IMPRIMINDO O DATA DE GETUSERINFO")/* subset response data! */
                print(String(data: newData!, encoding: .utf8)!)
                if let userInfo = self.parseDataWithCodable(UserKey.self, data: newData!){
                    self.user = userInfo.user
                    print("MARCELA - this is my userInfo: \(userInfo)")
                }
            }else{
                //TODO: como tratar esse problema
            }
        }
        task.resume()
    }
    
    @IBAction func submitLocationButton(_ sender: Any) {
        
        //unwrap of user values
        guard let uniqueKey = user?.key, let firstName = user?.first_name, let lastName = user?.last_name, let mapString = locationString, let mediaURL = userLink, let latitude = locationAnnotation?.coordinate.latitude, let longitude = locationAnnotation?.coordinate.longitude else{
            print("couldn't find data in user")
            return
        }
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            let checkErrorResult = self.checkForErrors(data: data, response: response, error: error)
            if checkErrorResult{
                if let userPostLocationInfo = self.parseDataWithCodable(PostNewLocation.self, data: data!){
                    //TODO: decidir se devo verificar se o usuario já tem ou nao uma location postada
                }
                performUIUpdatesOnMain {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapVC") as! MapVC
                    self.present(controller, animated: true, completion: nil)
                }
            }else{
                //TODO: tratar esse problema
            }
        }
        task.resume()
    }
    
}
