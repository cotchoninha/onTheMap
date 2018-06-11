//
//  AddNewLocationVC.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 11/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

class AddNewLocationVC: UIViewController {
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var linkTextField: UITextField!
    
    @IBAction func findLocationButton(_ sender: Any) {
    }
    
}
