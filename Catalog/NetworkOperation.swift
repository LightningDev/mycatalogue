//
//  NetworkOperation.swift
//  Catalog
//
//  Created by Nhat Tran on 5/09/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//  References: Stackoverflow user Robert Ryan

import Foundation

/// Asynchronous NSOperation subclass for downloading

class NetworkOperation : AsynchronousOperation {
    let task: NSURLSessionTask
    
    init(session: NSURLSession, URL: NSURL) {
        task = session.downloadTaskWithURL(URL)
        super.init()
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
    
    // MARK: NSURLSessionDownloadDelegate methods
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        do {
            let manager = NSFileManager.defaultManager()
            let documents = try manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            let destinationURL = documents.URLByAppendingPathComponent(downloadTask.originalRequest!.URL!.lastPathComponent!)
            if manager.fileExistsAtPath(destinationURL.path!) {
                try manager.removeItemAtURL(destinationURL)
            }
            try manager.moveItemAtURL(location, toURL: destinationURL)
        } catch {
            print(error)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> String {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        //print("\(downloadTask.originalRequest!.URL!.absoluteString) \(progress)")
        return "\(progress)"
    }
    
    // MARK: NSURLSessionTaskDelegate methods
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        completeOperation()
        if error != nil {
            print(error)
        }
    }
    
}


//
//  AsynchronousOperation.swift
//
//  Created by Robert Ryan on 9/20/14.
//  Copyright (c) 2014 Robert Ryan. All rights reserved.
//

/// Asynchronous Operation base class
///
/// This class performs all of the necessary KVN of `isFinished` and
/// `isExecuting` for a concurrent `NSOperation` subclass. So, to developer
/// a concurrent NSOperation subclass, you instead subclass this class which:
///
/// - must override `main()` with the tasks that initiate the asynchronous task;
///
/// - must call `completeOperation()` function when the asynchronous task is done;
///
/// - optionally, periodically check `self.cancelled` status, performing any clean-up
///   necessary and then ensuring that `completeOperation()` is called; or
///   override `cancel` method, calling `super.cancel()` and then cleaning-up
///   and ensuring `completeOperation()` is called.

public class AsynchronousOperation : NSOperation {
    
    override public var asynchronous: Bool { return true }
    
    private let stateLock = NSLock()
    
    private var _executing: Bool = false
    
    var operationStarted: Bool = false
    
    override private(set) public var executing: Bool {
        get {
            return stateLock.withCriticalScope { _executing }
        }
        set {
            willChangeValueForKey("isExecuting")
            stateLock.withCriticalScope { _executing = newValue }
            didChangeValueForKey("isExecuting")
        }
    }
    
    private var _finished: Bool = false
    override private(set) public var finished: Bool {
        get {
            return stateLock.withCriticalScope { _finished }
        }
        set {
            willChangeValueForKey("isFinished")
            stateLock.withCriticalScope { _finished = newValue }
            didChangeValueForKey("isFinished")
        }
    }
    
    /// Complete the operation
    ///
    /// This will result in the appropriate KVN of isFinished and isExecuting
    
    public func completeOperation() {
        
        if (!operationStarted) {
            return
        }
        
        if executing {
            executing = false
        }
        
        if !finished {
            finished = true
        }
    }
    
    override public func start() {
        operationStarted = true
        if cancelled {
            finished = true
            return
        }
        
        executing = true
        
        main()
    }
    
    override public func main() {
        fatalError("subclasses must override `main`")
    }
}

/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 An extension to `NSLock` to simplify executing critical code.
 
 From Advanced NSOperations sample code in WWDC 2015 https://developer.apple.com/videos/play/wwdc2015/226/
 From https://developer.apple.com/sample-code/wwdc/2015/downloads/Advanced-NSOperations.zip
 */


extension NSLock {
    
    /// Perform closure within lock.
    ///
    /// An extension to `NSLock` to simplify executing critical code.
    ///
    /// - parameter block: The closure to be performed.
    
    func withCriticalScope<T>(@noescape block: Void -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
