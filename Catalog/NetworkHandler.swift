//
//  NetworkHandler.swift
//  Catalog
//
//  Created by Nhat Tran on 9/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation

class NetworkHandler {
    let endPointUrl: String
    let username: String
    let password: String
    
    init(endPointUrl: String, username: String, password: String) {
        self.endPointUrl = endPointUrl
        self.username = username
        self.password = password
    }
    
    func convertToDict(jsonStr: NSData, checkCode: String?=nil) -> NSDictionary {
        do {
            if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(jsonStr, options: []) as? NSDictionary {
                
                return convertedJsonIntoDict
                
            }
        } catch let error as NSError {
            print(error.localizedDescription + "=" + checkCode!)
        }
        return NSDictionary()
    }
    
    // Download
    func getDataFromUrl(url: NSURL, completion: ((data: NSData!, response: NSURLResponse!, error: NSError!) -> Void)) {
        
        NSURLSession.sharedSession().dataTaskWithURL(url){ (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue()) {
                if (data != nil) {
                    completion(data: data, response: response, error: error)
                } else {
                    completion(data: nil, response: response, error: error)
                }
            }
            
            }.resume()
    }
    
    func downloadImage(url: NSURL, completion: ((data: NSData!, response: NSURLResponse!, error: NSError!) -> Void)) {
        
        let request = NSMutableURLRequest(URL: url)
        
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        urlconfig.timeoutIntervalForRequest = 120
        urlconfig.timeoutIntervalForResource = 120
        
        let session = NSURLSession(configuration: urlconfig)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in

            dispatch_async(dispatch_get_main_queue()) {
                if (data != nil) {
                    completion(data: data, response: response, error: error)
                } else {
                    completion(data: nil, response: response, error: error)
                }
            }
            
        })
        task.resume()
        
        //        NSURLSession.sharedSession().dataTaskWithURL(url){ (data, response, error) in
        //
        //            dispatch_async(dispatch_get_main_queue()) {
        //                if (data != nil) {
        //                    completion(data: data, response: response, error: error)
        //                } else {
        //                    completion(data: nil, response: response, error: error)
        //                }
        //            }
        //
        //            }.resume()
    }
    
    // GET Request
    func sendGetRequest(additionalURl: String, parameters: String, completionHandler: (NSData?, NSError?) -> ()) -> NSURLSessionTask {
        // Full URL
        let realURL = endPointUrl + additionalURl + parameters
        
        // NSURL Object
        let myNSURL = NSURL(string: realURL)
        
        // URL Request
        let myRequest = NSMutableURLRequest(URL: myNSURL!)
        myRequest.HTTPMethod = "GET"
        
        // Basic Authorization
        let loginString =  NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        myRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        // Excute HTTP Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(myRequest) { data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                if data != nil {
                    completionHandler(data, nil)
                }else {
                    completionHandler(nil, error)
                    return
                }
            }
            
        }
        
        task.resume();
        
        return task
    }
    
    func sendPostRequest(additionalURl: String, parameters: String, completionHandler: (NSData?, NSError?) -> ()) -> NSURLSessionTask {
        // Full URL
        let realURL = endPointUrl + additionalURl + parameters
        
        // NSURL Object
        let myNSURL = NSURL(string: realURL)
        
        // URL Request
        let myRequest = NSMutableURLRequest(URL: myNSURL!)
        myRequest.HTTPMethod = "POST"
        
        // Basic Authorization
        let loginString =  NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        myRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        // Excute HTTP Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(myRequest) { data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                if data != nil {
                    completionHandler(data, nil)
                }else {
                    completionHandler(nil, error)
                    return
                }
            }
            
        }
        
        task.resume();
        
        return task
    }
    
    func sendPutRequest(additionalURl: String, parameters: String) {
        
    }
    
    func sendDeleteRequest(additionalURl: String, parameters: String) {
        
    }
}