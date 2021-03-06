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
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    var locationAnnotation: MKPointAnnotation?
    var locationString: String?
    var userLink: String?
    var user: User?
    var appDelegate: AppDelegate!
    
    
    //MARK: Methods
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        ParseAPIClient.sharedInstance().getUserInfo(accountKey: appDelegate.keyAccount!) { (success, user, error) in
            if success{
                self.user = user
            }else{
                UserAlertManager.showAlert(title: "Invalid User", message: "Sorry, we couldn't obtain the user's information.", buttonMessage: "Try logging in again.", viewController: self)
            }
        }
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
    
    
    @IBAction func submitLocationButton(_ sender: Any) {
        
        ParseAPIClient.sharedInstance().submitLocation(uniqueKey: user?.key, firstName: user?.first_name, lastName: user?.last_name, mapString: locationString, mediaURL: userLink, latitude: locationAnnotation?.coordinate.latitude, longitude: locationAnnotation?.coordinate.longitude) { (success, postNewLocation, error) in
            if success{
                performUIUpdatesOnMain {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "UsersTabBarController")
                    self.present(controller, animated: true, completion: nil)
                }
            }else{
                UserAlertManager.showAlert(title: "Submission failed.", message: "Sorry, we couldn't post your location.", buttonMessage: "Try again.", viewController: self)
            }
        }
    }
    
}
