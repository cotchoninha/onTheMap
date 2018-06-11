//
//  Students.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 07/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit

struct Student: Codable {
    
    static var allStudents = [Student]()
    
    var objectId: String?
    var latitude: Float?
    var mapString: String?
    var uniqueKey: String?
    var lastName: String?
    var firstName: String?
    var longitude: Float?
    var mediaURL: String?
    var createdAt: String?
    var updatedAt: String?
    
}

struct StudentResult: Codable {
    var results: [Student]?
}
