//
//  Materials.swift
//  Catalog
//
//  Created by Nhat Tran on 28/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import RealmSwift

class Materials: Object {
    dynamic var code = ""
    dynamic var desc: String?
    dynamic var path: String?
    dynamic var stock: Double = 0.0
    dynamic var cash_p_m: Double = 0.0
    dynamic var image = NSData()
    
    override static func indexedProperties() -> [String] {
        return ["code"]
    }
}