//
//  NetworkList.swift
//  Catalog
//
//  Created by Nhat Tran on 5/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation

enum NetworkList: String {
    case Username = "OPTO"
    case Password = "opto"
    case Address = "http://192.168.222.116:8000"
    case MatgroupAddress = "/api/matgroup"
    case ImagesAddress = "/sample/image.zip"
    case offline = "/api/offlinemat"
    case ClientAddress = "/api/clients"
    case SubMaterialGroupAddress = "/api/submatgroup"
    case SalesOrderAddress = "/api/salesorder"
    case Employees = "/api/employee"
}