//
//  DownloadManager.swift
//  Download Handler for syncing the data from OPTO to iOS application
//
//  Created by Nhat Tran on 30/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import RealmSwift

class DownloadManager {
    
    var materials = [Materials]()
    var materialGroups = [String: [MaterialGroups]]()
    var subMaterialGroups = [String: [SubMaterialGroups]]()
    
    // Download catalogue
    func downloadAllCatalogue(apiRequest: dispatch_group_t) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.offline.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        
        // Call it
        dispatch_group_enter(apiRequest)
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {

                let dict: NSDictionary = networkHandler.convertToDict(response!)
                
                if (dict.count > 0) {
                    let jsonArr  = dict["items"] as! NSArray
                    let jsonCnt: Int = jsonArr.count
                    for i in 0..<jsonCnt {
                        let item = jsonArr[i]

                        let material_code = String(item["material_code"]!!)
                        let description = String(item["description"]!!)
                        let part_group = String(item["part_group"]!!)
                        let material_group_sub = String(item["material_group_sub"]!!)
                    
                        if (material_code != " ") {
                            
                            // Materials
                            var mat = Materials()
                            mat.code = material_code
                            mat.desc = description
                            
                            if (String(item["stock"]!!) != "<null>") {
                                mat.stock = Double(String(item["stock"]!!))!
                            }
                            
                            if (String(item["cash_p_m"]!!) != "<null>") {
                                mat.cash_p_m = Double(String(item["cash_p_m"]!!))!
                            }
                            
//                            // Material Groups
//                            if (part_group != "<null>") {
//                                var matGroup = MaterialGroups()
//                                matGroup.code = part_group
//                                matGroup.materials.append(mat)
//                                self.materialGroups.append(matGroup)
//                                if (self.materialGroups[code] != nil) {
//                                    self.materialGroups[code] = [MaterialGroups]()
//                                } else {
//                                    
//                                }
//                            }
//                            
//                            // Sub Material Groups
//                            if (material_group_sub != "<null>") {
//                                var subMatGroup = SubMaterialGroups()
//                                subMatGroup.code = String(item["material_group_sub"]!!)
//                                subMatGroup.materials.append(mat)
//                                self.subMaterialGroups.append(subMatGroup)
//                            }
                            
                            self.materials.append(mat)
                        }
                    }
                }
                dispatch_group_leave(apiRequest)
            }else {
                print(error)
                return
            }
        }
    }
    
    func importMaterialToRealm() {
        let realm = try! Realm()
        let groupCnt = materialGroups.count
        let subGroupCnt = subMaterialGroups.count
        
//        for i in 0..<groupCnt {
//            BackgroundFunctions.insertRow(self.materialGroups[i])
//        }
//        
//        for i in 0..<subGroupCnt {
//            
//            let subMatItemCnt = subMaterialGroups[i].materials.count
//            
//            for j in 0..<subMatItemCnt {
//                realm.add(subMaterialGroups[i].materials[j], update: true)
//            }
//            
//            BackgroundFunctions.insertRow(self.subMaterialGroups[i])
//        }
    }
    
    

}