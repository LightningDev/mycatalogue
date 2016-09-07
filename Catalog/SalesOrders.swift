//
//  SalesOrders.swift
//  Catalog
//
//  Created by Nhat Tran on 26/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import RealmSwift

class SalesOrders {
    
    var salesOrders = [SalesOrder]()
    var alphaSalesOrders: [String: [SalesOrder]]
    var alphaIndex = [String]()
    
    init() {
        self.alphaSalesOrders = [String: [SalesOrder]]()
        //setupDictionary()
    }
    
    func getFromRealm() {
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let results: Results<SalesOrder> = realm.objects(SalesOrder.self)
        self.salesOrders = Array(results)
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
    
    func sortAlphaIndex() {
        for i in 0..<salesOrders.count {
            let sale = salesOrders[i]
            if (!self.alphaIndex.contains(sale.customer)) {
                self.alphaIndex.append(sale.customer)
                self.alphaSalesOrders[sale.customer] = [SalesOrder]()
            }
        }
 
    }
    
    // Import to Realm
    func downloadSalesOrder() {
        let apiRequest = dispatch_group_create()
        importSales(apiRequest)
        dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
            let cnt = self.salesOrders.count
            for i in 0..<cnt {
                BackgroundFunctions.insertRow(self.salesOrders[i])
                print("Import Sale \(i)/\(cnt)")
            }
        }
    }
    
}