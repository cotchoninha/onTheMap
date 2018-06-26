//
//  Students.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 07/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct StudentInformation: Codable {
    
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
    var results: [StudentInformation]?
}

struct UserKey: Codable{
    var user: User?
}

struct User: Codable{
    var first_name: String?
    var last_name: String?
    var key: String?
}

struct PostNewLocation: Codable{
    var createdAt: String?
    var objectId: String?
}

struct PostLocationDataHTTPBody: Encodable{
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
}

