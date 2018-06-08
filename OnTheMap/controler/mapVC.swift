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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //atribuindo delegate ao mapView
        mapView.delegate = self
    }
    
    
    
    
    
}
