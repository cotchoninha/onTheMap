//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 18/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation

class ParseAPIClient: NSObject {
    
    func parseDataWithCodable(data: Data) -> [Student]? {
        
        let jsonDecoder = JSONDecoder()
        do{
            let studentsResult = try jsonDecoder.decode(StudentResult.self, from: data)
            return studentsResult.results
        } catch{
            print("Could not parse the data as JSON: '\(data)'")
            return nil
        }
    }
    
    
    func getStudendLocation( _ completionHandlerForPOST: @escaping (_ success: Bool, _ allStudentsArray: [Student]?, _ error: Error?) -> Void){
        
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
}
