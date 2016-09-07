//
//  SavedOrders.swift
//  Catalog
//
//  Created by Nhat Tran on 24/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import RealmSwift

class SavedOrders: Object {
    dynamic var code = ""
    dynamic var part_code = ""
    dynamic var customer = ""
    dynamic var project = ""
    
    override static func primaryKey() -> String? {
        return "code"
    }
}
