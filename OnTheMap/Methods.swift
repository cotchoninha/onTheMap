////
////  Methods.swift
////  OnTheMap
////
////  Created by Marcela Ceneviva Auslenter on 07/06/2018.
////  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
////
//
//import Foundation
//
////preciso de uma struct de Students com todas as caracteristicas dos students
////o conjunto desses students vai ser uma array de Students
//
//
//class Methods: NSObject{
//    
//    static var sharedsession = URLSession.shared
//    
//    func getMultipleStudentsLocations(method:String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{
//        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
//        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr")
//        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
//        let session = URLSession.shared
//        let task = session.dataTask(with: request) { data, response, error in
//            func sendError(_ error: String) {
//                print(error)
//            }
//            
//            /* GUARD: Was there an error? */
//            guard (error == nil) else {
//                sendError("There was an error with your request: \(error!)")
//                return
//            }
//            
//            /* GUARD: Did we get a successful 2XX response? */
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                sendError("Your request returned a status code other than 2xx!")
//                return
//            }
//            
//            /* GUARD: Was there any data returned? */
//            guard let data = data else {
//                sendError("No data was returned by the request!")
//                return
//            }
//            
//            let parsedResult: [String:AnyObject]!
//            do{
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
//            } catch{
//                sendError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//            //preciso pegar o nome do parsedresult e link
//            guard let id = parsedResult["id"], let uniqueKey = parsedResult["uniqueKey"], let firstName = parsedResult["firstName"], let lastName = parsedResult["lastName"], let mapString = parsedResult["mapString"], let mediaURL = parsedResult["mediaURL"], let latitude = parsedResult["latitude"], let longitude = parsedResult["longitude"], let createdAt = parsedResult["createdAt"], let id = parsedResult["updatedAt"],  else{
//                sendError("couldn't find a name on firstName key")
//                return
//            }
//
//            //fazer alguma coisa com o nome
//            print(studentName)
//        }
//        task.resume()
//    }
//    
//    
//    
//}
