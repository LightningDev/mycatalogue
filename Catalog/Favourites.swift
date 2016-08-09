//
//  Favourite.swift
//  Catalog
//
//  Created by Nhat Tran on 12/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import RealmSwift

class Favourite: Object {
    dynamic var group = ""
    dynamic var code = ""
    let objects = List<Object>()
    
    override static func primaryKey() -> String? {
        return "code"
    }

}