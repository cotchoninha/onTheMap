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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findLocationButtonOutlet: UIButton!
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if (urlString.range(of: "https://") != nil){
                if let url = URL(string: urlString){
                    // check if your application can open the NSURL instance
                    return UIApplication.shared.canOpenURL(url)
                }
            }else{
                if let url = URL(string: "https://\(urlString)"){
                    return UIApplication.shared.canOpenURL(url)
                }
            }
        }
        return false
    }
    
    @IBAction func findLocationButton(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        findLocationButtonOutlet.isEnabled = false
   
        if locationTextField.text == "" || locationTextField.text == nil{
            UserAlertManager.showAlert(title: "INVALID LOCATION", message: "Please, enter a valid location", buttonMessage: "Ok!", viewController: self)
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            findLocationButtonOutlet.isEnabled = true
        }else if linkTextField.text == "" || verifyUrl(urlString: linkTextField.text) == false{
            //checar se é o link URL
            UserAlertManager.showAlert(title: "INVALID LINK", message: "Please, enter a valid link", buttonMessage: "Ok!", viewController: self)
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            findLocationButtonOutlet.isEnabled = true
        }else{
            let locationString = locationTextField.text
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(locationString!) { (clPlacemarks, error) in
                if error != nil{
                    print(error?.localizedDescription)
                    UserAlertManager.showAlert(title: "Location not found.", message: "We couldn't find your location. Please, try changing your search parameters.", buttonMessage: "Try again.", viewController: self)
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
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.findLocationButtonOutlet.isEnabled = true
                    }
                }
            }
        }
    }
}
