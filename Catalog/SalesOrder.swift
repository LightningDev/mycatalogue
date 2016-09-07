//
//  SalesOrder.swift
//  Catalog
//
//  Created by Nhat Tran on 26/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import RealmSwift

class SalesOrder: Object {
    dynamic var code = ""
    dynamic var part_code = ""
    dynamic var customer = ""
    dynamic var project = ""
    
    override static func indexedProperties() -> [String] {
        return ["code"]
    }
    
    override static func primaryKey() -> String? {
        return "code"
    }
}
