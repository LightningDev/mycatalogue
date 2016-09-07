//
//  BackgroundFunctions.swift
//  Catalog
//
//  Created by Nhat Tran on 21/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import SystemConfiguration
import RealmSwift

public class BackgroundFunctions {
    
    static var currentUser = Employees()
    
    static var defaultClient = Contacts()
    
    class func setdefaultClient(user: Contacts) {
        defaultClient = user
    }
    
    class func getdefaultClient() -> Contacts {
        return defaultClient
    }
    
    
    class func setCurrentUser(user: Employees) {
        currentUser = user
    }
    
    class func getCurrentUser() -> Employees {
        return currentUser
    }
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
        
    }
    
    class func getRow(object: Object) {
        
    }
    
    class func insertRow(object: Object) {
        mitigrateRealm()
        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    }
    
    class func modifyRow(object: Object) {
        mitigrateRealm()
        let realm = try! Realm()
        try! realm.write {
            realm.add(object, update: true)
        }
    }
    
    class func deleteRow(object: Object) {
        mitigrateRealm()
        let realm = try! Realm()
        try! realm.write {
            realm.delete(object)
        }
    }
    
    class func updateRow() {
        
    }
    
    class func mitigrateRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 18,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 18) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

    }
    
    class func cleanDatabase() {
        mitigrateRealm()
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    class func createDirectory() {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let logsPath = documentsPath.URLByAppendingPathComponent("CatalogueImages")
        if (NSFileManager.defaultManager().fileExistsAtPath(logsPath.path!)) {
            return
        }
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(logsPath.path!, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    class func getImageDirectory() -> NSURL {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let logsPath = documentsPath.URLByAppendingPathComponent("CatalogueImages")
        return logsPath
    }
}