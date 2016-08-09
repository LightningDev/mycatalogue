//
//  SalesOrders.swift
//  Catalog
//
//  Created by Nhat Tran on 26/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation

class SalesOrders {
    
    var salesOrders = [SalesOrder]()
    var alphaSalesOrders: [String: [SalesOrder]]
    var alphaIndex = [String]()
    
    init() {
        self.alphaSalesOrders = [String: [SalesOrder]]()
        //setupDictionary()
    }
    
    // Request sales from API
    func importSales(apiRequest: dispatch_group_t? = nil) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.SalesOrderAddress.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        self.salesOrders.removeAll()
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
                    let sale = SalesOrder()
                    let item = jsonArr[i]
                    
                    sale.code = String(item["order_no"]!!)
                    sale.customer = String(item["customer"]!!)
                    sale.part_code = String(item["part_code"]!!)
                    sale.project = String(item["project"]!!)
                    
                    self.salesOrders.append(sale)
                    if (!self.alphaIndex.contains(sale.customer)) {
                        self.alphaIndex.append(sale.customer)
                        self.alphaSalesOrders[sale.customer] = [SalesOrder]()
                    }
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
    
    func getSectionCount(character: String) -> Int {
        for i in 0..<self.alphaIndex.count {
            let name = self.alphaIndex[i]
            if (name[0] == character) {
                return i
            }
        }
        return 0
    }
    
    func setupDictionary() {
        for i in 0..<self.salesOrders.count {
            let item = self.salesOrders[i]
            self.alphaSalesOrders[item.customer]?.append(item)
        }
    }
    
    // Import to Realm
    func downloadContact() {
//        let apiRequest = dispatch_group_create()
//        importContact(apiRequest)
//        dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
//            for i in 0..<self.contacts.count {
//                BackgroundFunctions.insertRow(self.contacts[i])
//            }
//        }
    }
    
}