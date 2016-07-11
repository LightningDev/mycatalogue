//
//  Catalogue.swift
//  Catalog
//
//  Created by Nhat Tran on 5/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import UIKit
import SSZipArchive
import RealmSwift

class Catalogue {
    
    var update: Bool = false
    var finish: Bool = true
    // Material group
    var materialGroups = [MaterialGroups]()
    var countGroup: Int {
        return materialGroups.count
    }
    
    // Sub Material
    
    // Empty constructor
    init() {
        // To-do-later
    }
    
    // Download data to object and import it to Realm
    func downloadFromServer() {
        downloadMaterialGroup()
    }
    
    func getFromRealm() {
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let results: Results<MaterialGroups> = realm.objects(MaterialGroups.self)
        self.materialGroups = Array(results)
    }
    
    func importMaterial(apiRequest: dispatch_group_t? = nil) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.MatgroupAddress.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        self.materialGroups.removeAll()
        // Call it
        if (apiRequest != nil) {
            dispatch_group_enter(apiRequest!)
        }
        
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                let jsonArr  = dict["_embedded"]!["item"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    var materialGroup = MaterialGroups()
                    let item = jsonArr[i]
                    materialGroup.code = String(item["code"]!!)
                    materialGroup.desc = String(item["description"]!!)
                    self.materialGroups.append(materialGroup)
                }
                if (apiRequest != nil) {
                    dispatch_group_leave(apiRequest!)
                }
            }else {
                print(error)
                return
            }
        }
    }
    
    func importSubMaterial(code: String, index: Int, apiRequest: dispatch_group_t? = nil) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.MatgroupAddress.rawValue + "/" + code
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        self.materialGroups[index].materials.removeAll()
        // Call it
        if (apiRequest != nil) {
            dispatch_group_enter(apiRequest!)
        }
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!, checkCode: code)
                if (dict.count == 0 ) {
                    return
                }
                let jsonArr  = dict["_embedded"]!["materials"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    let testItem = Materials()
                    testItem.code = String(item["material_code"]!!)
                    testItem.desc = String(item["description"]!!)
                    testItem.stock = Double(String(item["stock"]!!))!
                    testItem.path = String(item["path"]!!)
                    self.materialGroups[index].materials.append(testItem)
                }
                print("Current checkCount of \(code)")
                if (apiRequest != nil) {
                    dispatch_group_leave(apiRequest!)
                }
            }else {
                print(error)
                return
            }
        }
    }
    
    // Download material group
    private func downloadMaterialGroup() {
        // Declare api header
        let group = dispatch_group_create()
        let url: String = NetworkList.Address.rawValue + NetworkList.MatgroupAddress.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        // Call it
        dispatch_group_enter(group)
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                
                let jsonArr  = dict["_embedded"]!["item"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    
                    // test
                    var materialGroup = MaterialGroups()
                    materialGroup.code = String(item["code"]!!)
                    materialGroup.desc = String(item["description"]!!)
                    self.materialGroups.append(materialGroup)
                }
                dispatch_group_leave(group)
            }else {
                print(error)
                return
            }
        }
        
        // Notify asynchronous completion
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            print("Start downloading sub material")
            let apiGroup = dispatch_group_create()
            
            for i in 0..<self.countGroup {
                self.downloadSubMaterial(self.materialGroups[i].code, index: i, apiGroup: apiGroup)
            }
            
            // Notify asynchronous completion
            dispatch_group_notify(apiGroup, dispatch_get_main_queue()) {
                print("Finished all")
                BackgroundFunctions.createDirectory()
                self.downloadImage()
            }
        }
    }
    
    // Download sub material
    private func downloadSubMaterial(code: String, index: Int, apiGroup: dispatch_group_t) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.MatgroupAddress.rawValue + "/" + code
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        // Call it
        dispatch_group_enter(apiGroup)
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!, checkCode: code)
                if (dict.count == 0 ) {
                    dispatch_group_leave(apiGroup)
                    //print("Ignored \(matGroup.code) because of unexpected characters")
                    return
                }
                let jsonArr  = dict["_embedded"]!["materials"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    
                    // test
                    let testItem = Materials()
                    testItem.code = String(item["material_code"]!!)
                    testItem.desc = String(item["description"]!!)
                    testItem.stock = Double(String(item["stock"]!!))!
                    testItem.path = BackgroundFunctions.getImageDirectory().URLByAppendingPathComponent("image.jpg").path!
                    self.materialGroups[index].materials.append(testItem)
                }
                print("Current checkCount of \(code)")
                dispatch_group_leave(apiGroup)
            }else {
                print(error)
                return
            }
        }
    }
    
    // test download image
    func downloadImage() {
        let group = dispatch_group_create()
        let networkHandler = NetworkHandler(endPointUrl: "", username: "", password: "")
        let url = NSURL(string: (NetworkList.Address.rawValue + NetworkList.ImagesAddress.rawValue))
        dispatch_group_enter(group)
        networkHandler.getDataFromUrl(url!) { data, response, error in
            if (data != nil) {
                let filePath = BackgroundFunctions.getImageDirectory().URLByAppendingPathComponent("images")
                data.writeToURL(filePath, atomically: true)
                SSZipArchive.unzipFileAtPath(filePath.path!, toDestination: BackgroundFunctions.getImageDirectory().path!)
            } else {
                print(error)
            }
            dispatch_group_leave(group)
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            if (self.update) {
                // insert to realm
                for i in 0..<self.countGroup {
                    BackgroundFunctions.insertRow(self.materialGroups[i])
                }
            }
            self.finish = true
        }
        
    }
}