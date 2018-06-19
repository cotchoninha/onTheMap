//
//  AddNewLocationVC.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 11/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit


class AddNewLocationVC: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!

    //MARK: Methods
    func alert(title: String, message: String, buttonMessage: String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: buttonMessage, style: UIAlertActionStyle.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func findLocationButton(_ sender: Any) {
        locationTextField.text = "Campinas, Brazil"
        linkTextField.text = "www.udacity.com"
        if locationTextField.text == "" || locationTextField.text == nil{
            alert(title: "INVALID LOCATION", message: "Please, enter a valid location", buttonMessage: "Ok!")
        }else if linkTextField.text == ""{
            //checar se é o link URL
            self.alert(title: "INVALID LINK", message: "Please, enter a valid link", buttonMessage: "Ok!")
        }else{
            let locationString = locationTextField.text
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationString!) { (clPlacemarks, error) in
                if error != nil{
                    print(error?.localizedDescription)
                } else if let placemarks = clPlacemarks, placemarks.count > 0{
                    let placemark = placemarks[0]
                    if let location = placemark.location{
                        let coordinate = location.coordinate
                        let latitude = CLLocationDegrees(coordinate.latitude)
                        let longitude = CLLocationDegrees(coordinate.longitude)
                        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinates
                        annotation.title = locationString
                        let controller = self.storyboard!.instantiateViewController(withIdentifier: "AddMap") as! AddMapViewController
                        controller.locationAnnotation = annotation
                        controller.locationString = locationString
                        controller.userLink = self.linkTextField.text
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
