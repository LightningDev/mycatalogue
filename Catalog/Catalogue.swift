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
    var subMaterialGroups = [SubMaterialGroups]()
    var materials = [Materials]()
    var countGroup: Int {
        return materialGroups.count
    }
    var countSubGroup: Int {
        return subMaterialGroups.count
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
    
    func getSubFromRealm() {
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let results: Results<SubMaterialGroups> = realm.objects(SubMaterialGroups.self)
        self.subMaterialGroups = Array(results)
    }
    
    // Get all materials
    func getAllFromRealm() {
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let results: Results<Materials> = realm.objects(Materials.self)
        self.materials = Array(results)
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
                    let materialGroup = MaterialGroups()
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
    
    // download submaterialgroup
    func importSubMaterialGroup(apiGroup: dispatch_group_t) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.SubMaterialGroupAddress.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        self.subMaterialGroups.removeAll()
        // Call it
        dispatch_group_enter(apiGroup)
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                
                let jsonArr  = dict["_embedded"]!["item"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    
                    // test
                    let materialGroup = SubMaterialGroups()
                    materialGroup.code = String(item["code"]!!)
                    materialGroup.desc = String(item["description"]!!)
                    self.subMaterialGroups.append(materialGroup)
                    
                }
                dispatch_group_leave(apiGroup)
            }else {
                print(error)
                return
            }
        }
        
        // Notify asynchronous completion
        dispatch_group_notify(apiGroup, dispatch_get_main_queue()) {
            //print("Start downloading sub material")
            let group = dispatch_group_create()
            
            for i in 0..<self.countSubGroup {
                self.downloadItemInSubMaterialGroup(self.subMaterialGroups[i].code, index: i, apiRequest: group)
            }
        }
    }
    
    // download submaterialgroup
    func downloadSubMaterialGroup() {
        // Declare api header
        let apiGroup = dispatch_group_create()
        let url: String = NetworkList.Address.rawValue + NetworkList.SubMaterialGroupAddress.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        self.subMaterialGroups.removeAll()
        // Call it
        dispatch_group_enter(apiGroup)
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                
                let jsonArr  = dict["_embedded"]!["item"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    
                    // test
                    let materialGroup = SubMaterialGroups()
                    materialGroup.code = String(item["code"]!!)
                    materialGroup.desc = String(item["description"]!!)
                    self.subMaterialGroups.append(materialGroup)
                    
                }
                dispatch_group_leave(apiGroup)
            }else {
                print(error)
                return
            }
        }
        
        // Notify asynchronous completion
        dispatch_group_notify(apiGroup, dispatch_get_main_queue()) {
            //print("Start downloading sub material")
            let fuckingapigroup = dispatch_group_create()
            
            for i in 0..<self.countSubGroup {
                self.downloadItemInSubMaterialGroup(self.subMaterialGroups[i].code, index: i, apiRequest: fuckingapigroup)
            }
            
            dispatch_group_notify(fuckingapigroup, dispatch_get_main_queue()) {
                self.writeToRealmSub()
            }
        }
    }
    
    func downloadItemInSubMaterialGroup(code: String, index: Int, apiRequest: dispatch_group_t) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.SubMaterialGroupAddress.rawValue + "/" + code
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        // Call it
        dispatch_group_enter(apiRequest)
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
                    if (String(item["cash_p_m"]!!) != "<null>") {
                        testItem.cash_p_m = Double(String(item["cash_p_m"]!!))!
                    }
                    self.subMaterialGroups[index].materials.append(testItem)
                }
                dispatch_group_leave(apiRequest)
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
                    if (String(item["cash_p_m"]!!) != "<null>") {
                        testItem.cash_p_m = Double(String(item["cash_p_m"]!!))!
                    }
                    self.materialGroups[index].materials.append(testItem)
                }
                //print("Check this code mate \(code)")
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
        self.materialGroups.removeAll()
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
                    let materialGroup = MaterialGroups()
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
                self.writeToRealm()
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
                    //testItem.path = BackgroundFunctions.getImageDirectory().URLByAppendingPathComponent("image.jpg").path!
                    if (String(item["cash_p_m"]!!) != "<null>") {
                        testItem.cash_p_m = Double(String(item["cash_p_m"]!!))!
                    }
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
    
    // download Image
    func downloadImage(apiRequest: dispatch_group_t? = nil) {
     
        let apiRequest = dispatch_group_create()
     
        let networkHandler = NetworkHandler(endPointUrl: "", username: "", password: "")
        let url = NSURL(string: (NetworkList.Address.rawValue + NetworkList.ImagesAddress.rawValue))
        dispatch_group_enter(apiRequest)
        networkHandler.getDataFromUrl(url!) { data, response, error in
            if (data != nil) {
                let filePath = BackgroundFunctions.getImageDirectory().URLByAppendingPathComponent("images")
                data.writeToURL(filePath, atomically: true)
                SSZipArchive.unzipFileAtPath(filePath.path!, toDestination: BackgroundFunctions.getImageDirectory().path!)
            } else {
                print(error)
            }
            dispatch_group_leave(apiRequest)
        }
        
        dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
            if (self.update) {
                // insert to realm
                for i in 0..<self.countGroup {
                    BackgroundFunctions.insertRow(self.materialGroups[i])
                }
            }
            self.finish = true
        }
        
    }
    
    func writeToRealm() {
        for i in 0..<self.countGroup {
            BackgroundFunctions.insertRow(self.materialGroups[i])
        }
    }
    
    func writeToRealmSub() {
        for i in 0..<self.countSubGroup {
            print(self.subMaterialGroups[i].code)
            BackgroundFunctions.insertRow(self.subMaterialGroups[i])
        }
    }
    
    func toGroupNameArray() -> [String] {
        var returnString = [String]()
        for i in 0..<self.countGroup {
            returnString.append(materialGroups[i].desc!)
        }
        
        return returnString
    }
    
    func toSubGroupNameArray() -> [String] {
        var returnString = [String]()
        for i in 0..<self.countSubGroup {
            returnString.append(subMaterialGroups[i].desc!)
        }
        
        return returnString
    }
    
    func filterMaterials(searchText: String) -> [Materials]{
        var matTuples: [(code:String , desc: String)] = []
        var returnMat = [Materials]()
        for i in 0..<materials.count {
            matTuples += [(code:materials[i].code, desc:materials[i].desc!)]
        }
        
        let filtered = matTuples.filter({ (data) -> Bool in
            let codeSearch: NSString = data.code // the name from the variable decleration
            let descSearch: NSString = data.desc // the name from the variable decleration
            let codeSearchRange = codeSearch.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let descSearchRange = descSearch.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return (codeSearchRange.location != NSNotFound || descSearchRange.location != NSNotFound)
        })
        
        print(filtered.count)
        return returnMat
    }
    
    func forTheFuckSakeFilter(searchText: String) -> [Materials] {
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let someDogs = realm.objects(Materials.self).filter("code contains '\(searchText)'")
        return Array(someDogs)
    }
}