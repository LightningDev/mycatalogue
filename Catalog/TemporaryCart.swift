//
//  TemporaryCart.swift
//  Catalog
//
//  Created by Nhat Tran on 25/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import RealmSwift

class TemporaryCart: Object {
    
    dynamic var code = ""
    var cart = List<CatalogueCart>()
    
    override static func primaryKey() -> String? {
        return "code"
    }
}
