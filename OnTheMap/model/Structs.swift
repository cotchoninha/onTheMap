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
//criar uma struct vou ter uma var user: User
//criar uma struct para o meu tipo user

