//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 18/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation

class ParseAPIClient: NSObject {
    
    //singleton
    class func sharedInstance() -> ParseAPIClient {
        struct Singleton {
            static var sharedInstance = ParseAPIClient()
        }
        return Singleton.sharedInstance
    }
    
    //parse for student
    func parseDataWithCodable(data: Data) -> [StudentInformation]? {
        
        let jsonDecoder = JSONDecoder()
        do{
            let studentsResult = try jsonDecoder.decode(StudentResult.self, from: data)
            return studentsResult.results
        } catch{
            print("Could not parse the data as JSON: '\(data)'")
            return nil
        }
    }
    //parse generic type for userInfo
    func parseDataWithCodableGenericType<T: Decodable>(_ type: T.Type, data: Data) -> T? {
            
        let jsonDecoder = JSONDecoder()
        do{
            return try jsonDecoder.decode(type, from: data)
        } catch{
            print("Could not parse the data as JSON: '\(data)'")
            return nil
        }
    }
    
    //get multiple students locations
    func getStudentsLocations( _ completionHandlerForPOST: @escaping (_ success: Bool, _ allStudentsArray: [StudentInformation]?, _ error: Error?) -> Void){
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(false, nil, NSError(domain: "getStudendLocation", code: 1, userInfo: userInfo))
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
            
            if let studentsList = self.parseDataWithCodable(data: data){
                completionHandlerForPOST(true, studentsList, nil)
            }
        }
        task.resume()
    }
    
    //get the logged in Student info
    func getUserInfo(accountKey: String, _ completionHandlerForGET: @escaping (_ success: Bool, _ userInfo: User?, _ error: Error?) -> Void){
        
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(accountKey)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(false, nil, NSError(domain: "getStudendLocation", code: 1, userInfo: userInfo))
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
                let newData = data.subdata(in: range)
                print("MARCELA - IMPRIMINDO O DATA DE GETUSERINFO")/* subset response data! */
                print(String(data: newData, encoding: .utf8)!)
                if let userInfo = self.parseDataWithCodableGenericType(UserKey.self, data: newData){
                    completionHandlerForGET(true, userInfo.user, nil)
                    print("MARCELA - this is my userInfo: \(userInfo)")
                }
        }
        task.resume()
    }
    
    //post new User Location
    func submitLocation(uniqueKey: String?, firstName: String?, lastName: String?, mapString: String?, mediaURL: String?, latitude: Double?, longitude: Double?, _ completionHandlerForPOSTLOCATION: @escaping (_ success: Bool, _ PostNewLocation: PostNewLocation?, _ error: Error?) -> Void) {
        
        //unwrap of user values
        guard let uniqueKey = uniqueKey, let firstName = firstName, let lastName = lastName, let mapString = mapString, let mediaURL = mediaURL, let latitude = latitude, let longitude = longitude else{
            print("couldn't find data in user")
            return
        }
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //TODO FAZER ENCODE
        let encoder = JSONEncoder()
        let dataEncoded: Data
        do{
            dataEncoded = try encoder.encode(PostLocationDataHTTPBody(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude))
            request.httpBody = dataEncoded
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                func sendError(_ error: String) {
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerForPOSTLOCATION(false, nil, NSError(domain: "submitLocation", code: 1, userInfo: userInfo))
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
                
                if let userNewLocation = self.parseDataWithCodableGenericType(PostNewLocation.self, data: data){
                //TODO: decidir se devo verificar se o usuario já tem ou nao uma location postada
                    completionHandlerForPOSTLOCATION(true, userNewLocation, nil)
                }
                
            }
            task.resume()
        }catch{
            print("nao deu")
            dataEncoded = Data()
            //TODO: apresentar um alerta pro usuario
        }
    }

}
