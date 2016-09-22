//
//  SalesOrders.swift
//  Catalog
//
//  Created by Nhat Tran on 26/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation

class SalesDetails {
    
    var salesDetail = [Parts]()
    
    init() {
        //setupDictionary()
    }
    
    // Request sales from API
    func importSales(code: String, apiRequest: dispatch_group_t? = nil) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.SalesOrderAddress.rawValue + "/" + code
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        self.salesDetail.removeAll()
        // Call it
        if (apiRequest != nil) {
            dispatch_group_enter(apiRequest!)
        }
        
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                let jsonArr  = dict["_embedded"]!["items"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    let aloc_type = item["aloc_type"]
                    let due_date_1 = item["due_date_1"]
                    let ma = item["ma"]
                    let part_code_one = item["part_code_one"]
                    let part_desc = item["part_desc"]
                    let sum_one = item["sum_one"]
                    let tax_pro = item["tax_pro"]
                    let to_do = item["to_do"]
                    let total_amount_one = item["total_amount_one"]
                    let total_qty = item["total_qty"]
                    let partCnt = part_code_one!!.count
                    
                    for j in 0..<partCnt {
                        let part = Parts()
                        part.aloc_type = String(aloc_type!![j])
                        part.due_date_1 = String(due_date_1!![j])
                        part.ma = String(ma!![j])
                        part.code = String(part_code_one!![j])
                        part.desc = String(part_desc!![j])
                        part.sum_one = String(sum_one!![j])
                        part.tax_pro = String(tax_pro!![j])
                        part.to_do = String(to_do!![j])
                        part.total_amount_one = String(total_amount_one!![j])
                        part.total_qty = String(total_qty!![j])
                        self.salesDetail.append(part)
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
    
    // download sales order
//    func downloadSalesOrder() {
//        let apiRequest = dispatch_group_create()
//        importSales(apiRequest)
//        dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
//            let cnt = self.salesOrders.count
//            for i in 0..<cnt {
//                BackgroundFunctions.insertRow(self.salesOrders[i])
//                print("Import Sale \(i)/\(cnt)")
//            }
//        }
//    }
}