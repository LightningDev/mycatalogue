//
//  Parts.swift
//  Catalog
//
//  Created by Nhat Tran on 26/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import RealmSwift

enum PartType: String {
    case Material = "M"
    case Part = "P"
}

class Parts: Object {
    dynamic var code = ""
    dynamic var desc = ""
    dynamic var aloc_type = ""  // Part Type
    dynamic var due_date_1 = "" // Due Date
    dynamic var ma = "" // Disc
    dynamic var sum_one = ""    // Total
    dynamic var tax_pro = ""    // Tax
    dynamic var to_do = ""  // Desp
    dynamic var total_amount_one = ""   // Unit price
    dynamic var total_qty = ""  // Quantity
    
    override static func primaryKey() -> String? {
        return "code"
    }
    
    
}