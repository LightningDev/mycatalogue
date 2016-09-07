//
//  EmployeesInformation.swift
//  Catalog
//
//  Created by Nhat Tran on 26/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation

class EmployeesInformation {

    var employees = [Employees]()
    
    init() {
        
    }
    
    func getEmployeesFromServer(apiRequest: dispatch_group_t) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.Employees.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        self.employees.removeAll()
        
        dispatch_group_enter(apiRequest)
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                let jsonArr  = dict["_embedded"]!["item"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let emp = Employees()
                    let item = jsonArr[i]
                    emp.code = String(item["emp_code"]!!)
                    emp.name = String(item["emp_name"]!!)
                    emp.date_chk = String(item["date_chk"]!!)
                    emp.time_chk   = String(item["time_chk"]!!)
                    self.employees.append(emp)
                }
                
                dispatch_group_leave(apiRequest)
            }else {
                print(error)
                return
            }
        }
    }
    
}