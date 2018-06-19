//
//  UdacityAPIClient.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 17/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation

class UdacityAPIClient: NSObject{
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // MARK: POST
    
    func userLoginRequest(username: String, password: String, _ completionHandlerForPOST: @escaping (_ success: Bool,_ sessionID : String?,_ keyAccount : String?, _ error: Error?) -> Void){
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(false, nil, nil, NSError(domain: "userLoginRequest", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            print("AQUI COMECA A IMPRIMIR O DATA!!!!")
            print(String(data: newData, encoding: .utf8)!)
            
            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as? [String:AnyObject]
            } catch{
                sendError("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let dictionarySession = parsedResult["session"], let dictionaryAccount = parsedResult["account"] else{
                sendError("Cannot find keys 'session' in \(parsedResult)")
                return
            }
            if let sessionID = dictionarySession["id"] as? String, let keyAccount = dictionaryAccount["key"] as? String{
                completionHandlerForPOST(true, sessionID, keyAccount, nil)
            }else{
                sendError("could not find a SessionID.")
            }
        }
        task.resume()
    }
    
    
    func userLoginRequestWithFacebook(authenticationToken: String, _ completionHandlerForPOST: @escaping (_ success: Bool,_ sessionID : String?,_ keyAccount : String?, _ error: Error?) -> Void){
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(authenticationToken)\"}}".data(using: .utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(false, nil, nil, NSError(domain: "userLoginRequestWithFacebook", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            print("AQUI COMECA A IMPRIMIR O DATA!!!!")
            print(String(data: newData, encoding: .utf8)!)
            
            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]!
            do{
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as? [String:AnyObject]
            } catch{
                sendError("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            guard let dictionarySession = parsedResult["session"], let dictionaryAccount = parsedResult["account"] else{
                sendError("Cannot find keys 'session' in \(parsedResult)")
                return
            }
            if let sessionID = dictionarySession["id"] as? String, let keyAccount = dictionaryAccount["key"] as? String{
                completionHandlerForPOST(true, sessionID, keyAccount, nil)
            }else{
                sendError("could not find a SessionID.")
            }
        }
        task.resume()
    }
    
    func logoutUser(_ completionHandlerForDELETE: @escaping (_ success: Bool, _ error: Error?) -> Void){
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(false, NSError(domain: "logoutUser", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count)
            _ = data.subdata(in: range)
            completionHandlerForDELETE(true, nil)
            
            /* subset response data! */
            //should I use dismiss instead of calling the LoginVC again?
            
        }
        task.resume()

    }
}
