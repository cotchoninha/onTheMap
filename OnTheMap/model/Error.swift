//
//  Error.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 21/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation

enum LoginRequestERROR: Error{
    case connectionFailed
    case invalidUserImput
    case noDataReturned
}
