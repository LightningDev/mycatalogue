//
//  NetworkManager.swift
//  Catalog
//
//  Created by Nhat Tran on 5/09/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation

class NetworkManager: NSObject, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate {
    
    /// Dictionary of operations, keyed by the `taskIdentifier` of the `NSURLSessionTask`
    
    private var operations = [Int: NetworkOperation]()
    
    /// Single or multiple dispatch
    
    var waitForAll: Bool = true
    
    /// Multiple dispatchs in each operation
    
    var apiGroups = [Int: dispatch_group_t]()
    
    /// Dictionary of leave dispatchs
    
    var leaveGroups = [Int: Bool]()
    
    /// Single dispatchs for all operations
    
    var api = dispatch_group_create()
    
    /// OPTIONAL: images data after downloading
    
    var images = [Int: NSData]()
    
    /// OPTIONAL: download percentage
    var downloadPercentage = ""
    
    /// Delegate
    var delegate: NetworkManagerDelegate? = nil
    
    /// Serial NSOperationQueue for downloads
    
    let queue: NSOperationQueue = {
        let _queue = NSOperationQueue()
        _queue.name = "download"
        _queue.maxConcurrentOperationCount = 1
        
        return _queue
    }()
    
    /// Delegate-based NSURLSession for NetworkManager
    
    lazy var session: NSURLSession = {
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }()
    
    /// Add download
    ///
    /// - parameter URL:  The URL of the file to be downloaded
    ///
    /// - returns:        The NetworkOperation of the operation that was queued
    
    func addDownload(URL: NSURL) -> NetworkOperation {
        let operation = NetworkOperation(session: session, URL: URL)
        operations[operation.task.taskIdentifier] = operation
        
        // Check dispatch group type
        if (waitForAll) {
            dispatch_group_enter(api)
        } else {
            let apiGroup = dispatch_group_create()
            apiGroups[operation.task.taskIdentifier] = apiGroup
            leaveGroups[operation.task.taskIdentifier] = false
            dispatch_group_enter(apiGroup)
        }
        queue.addOperation(operation)
        return operation
    }
    
    /// Cancel all queued operations
    /// Also make sure all entered dispatchs are left
    func cancelAll() {
        if (waitForAll) {
            dispatch_group_leave(api)
        } else {
            for i in 0..<leaveGroups.count {
                if (leaveGroups[i+1] == false) {
                    if (apiGroups[i+1] != nil) {
                        dispatch_group_leave(apiGroups[i+1]!)
                    }
                }
            }
        }
        queue.cancelAllOperations()
    }
    
    // Use with !WaitForAll
    func checkAllOperationsWereDone() -> Bool {
        for i in 0..<leaveGroups.count {
            if (leaveGroups[i+1] == false) {
                return false
            }
        }
        return true
    }
    
    // MARK: NSURLSessionDownloadDelegate methods
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        operations[downloadTask.taskIdentifier]?.URLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
        if (waitForAll) {
            dispatch_group_leave(api)
        } else {
            leaveGroups[downloadTask.taskIdentifier] = true
            dispatch_group_leave(apiGroups[downloadTask.taskIdentifier]!)
        }
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        downloadPercentage = (operations[downloadTask.taskIdentifier]?.URLSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite))!
        let percentage = Float(downloadPercentage)
        print(downloadPercentage)
        dispatch_async(dispatch_get_main_queue()) {
            self.delegate?.setProgressViewController(percentage!)
        }
    }
    
    // MARK: NSURLSessionTaskDelegate methods
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let key = task.taskIdentifier
        operations[key]?.URLSession(session, task: task, didCompleteWithError: error)
        operations.removeValueForKey(key)
    }
    
}