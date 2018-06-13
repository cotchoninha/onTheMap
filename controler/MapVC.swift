//
//  mapVC.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 05/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import MapKit
import UIKit
import CoreLocation

class MapVC: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStudendLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //atribuindo delegate ao mapView
        mapView.delegate = self
    }
    
    var allStudents = [Student]()
    var annotations = [MKPointAnnotation]()
    
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
    
    func getStudendLocation(){
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            self.checkForErrors(data: data, response: response, error: error)
            
            if let studentsList = self.parseDataWithCodable(data: data!){
                self.allStudents = studentsList
            }
            performUIUpdatesOnMain {
                self.addStudentLocationToMap()
            }
        }
        task.resume()
    }
    
    func addStudentLocationToMap(){
        
        
        for student in allStudents {
//            guard student.longitude != nil else{
//                return
//            }
            // se ltitude e long estiverem vazios nao adiciona
            if student.latitude == nil && student.longitude == nil{
                //nao adiciona
            } else{
                let latitude = CLLocationDegrees(student.latitude!)
                let longitude = CLLocationDegrees(student.longitude!)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                annotation.title = "\(student.firstName ?? "") \(student.lastName ?? "")"
                annotation.subtitle = student.mediaURL ?? ""
                
                // Finally we place the annotation in an array of annotations.
                
                annotations.append(annotation)
                
            }
            
          
        }
        self.mapView.addAnnotations(annotations)
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    
}
