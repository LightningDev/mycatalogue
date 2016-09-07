//
//  Employees.swift
//  Catalog
//
//  Created by Nhat Tran on 26/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import RealmSwift

class Employees: Object {
    dynamic var code = ""
    dynamic var name = ""
    dynamic var username = ""
    dynamic var password = ""
    dynamic var remember = false
    dynamic var date_chk = ""
    dynamic var time_chk = ""
    dynamic var permission = ""
    var clients = List<Contacts>()
    
    override static func primaryKey() -> String? {
        return "code"
    }
}
