//
//  MaterialGroups.swift
//  Catalog
//
//  Created by Nhat Tran on 28/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import RealmSwift

class MaterialGroups: Object {
    dynamic var code = ""
    dynamic var desc: String?
    let materials = List<Materials>()
    
    override static func indexedProperties() -> [String] {
        return ["code"]
    }
    
    override static func primaryKey() -> String? {
        return "code"
    }
}