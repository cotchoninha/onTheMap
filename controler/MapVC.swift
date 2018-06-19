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
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    var parseAPIClient = ParseAPIClient()
    var allStudents = [Student]()
    var annotations = [MKPointAnnotation]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parseAPIClient.getStudentsLocations {(success, studentsArray, error) in
            if success{
                performUIUpdatesOnMain {
                    self.allStudents = studentsArray!
                    self.addStudentLocationToMap()
                }
            }else{
                //tratar o erro
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //atribuindo delegate ao mapView
        mapView.delegate = self
    }
    
    func addStudentLocationToMap(){
        
        for student in allStudents {
            if student.latitude == nil && student.longitude == nil{
                //TODO: nao adiciona
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
