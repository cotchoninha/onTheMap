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
import FBSDKLoginKit

class MapVC: UIViewController, MKMapViewDelegate{
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    var parseAPIClient = ParseAPIClient()
    var udacityAPIClient = UdacityAPIClient()
    var allStudents = [StudentInformation]()
    var annotations = [MKPointAnnotation]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parseAPIClient.getStudentsLocations {(success, studentsArray, error) in
            performUIUpdatesOnMain {
                if success{
                    self.allStudents = studentsArray!
                    self.addStudentLocationToMap()
                    
                }else{
                    UserAlertManager.showAlert(title: "Empty list.", message: "Sorry, we couldn't obtain the other students locations.", buttonMessage: "Try logging in again.", viewController: self)
                }
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
    
    @IBAction func refreshButton(_ sender: Any) {
        parseAPIClient.getStudentsLocations {(success, studentsArray, error) in
            performUIUpdatesOnMain {
                if success{
                    self.allStudents = studentsArray!
                    self.addStudentLocationToMap()
                    
                }else{
                    UserAlertManager.showAlert(title: "Empty list.", message: "Sorry, we couldn't obtain the other students locations.", buttonMessage: "Try logging in again.", viewController: self)
                }
            }
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
    
    
}
