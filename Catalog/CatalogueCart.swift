//
//  CatalogueCarts.swift
//  Catalog
//
//  Created by Nhat Tran on 19/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//
import Foundation
import RealmSwift

class CatalogueCart: Object {
    dynamic var code = ""
    dynamic var created_date = NSDate()
    dynamic var cart_total_price: Double = 0.0
    dynamic var finished = false
    dynamic var user = ""
    dynamic var emp_no = ""
    dynamic var client_order_no = ""
    dynamic var address_1 = ""
    dynamic var address_2 = ""
    dynamic var city = ""
    dynamic var postcode = ""
    dynamic var country = ""
    
    var items = List<Parts>()
    
    override static func primaryKey() -> String? {
        return "code"
    }
    
    func toItems() -> AnyObject {
        
        var aloc_type_array = [String]()
        var part_code_one_array = [String]()
        var part_desc_array = [String]()
        var total_qty_array = [String]()
        var due_date_1_array = [String]()
        var ma_array = [String]()
        var sum_one_array = [String]()
        var tax_pro_array = [String]()
        var to_do_array = [String]()
        var total_amount_one_array = [String]()
        
        for i in 0..<items.count {
            aloc_type_array.append(items[i].aloc_type)
            part_code_one_array.append(items[i].code)
            part_desc_array.append(items[i].desc)
            total_qty_array.append(items[i].total_qty)
            due_date_1_array.append(items[i].due_date_1)
            ma_array.append(items[i].ma)
            sum_one_array.append(items[i].sum_one)
            tax_pro_array.append(items[i].tax_pro)
            to_do_array.append(items[i].to_do)
            total_amount_one_array.append(items[i].total_amount_one)
        }
        
        let partDict = [
            "order_no": code,
            "customer": user,
            "date": created_date,
            "emp": emp_no,
            "cust_order_no": client_order_no,
            "del_address": "\(address_1) \n \(address_2) \n \(city) \n \(postcode) \n \(country)",
            "aloc_type": aloc_type_array,
            "part_code_one": part_code_one_array,
            "part_desc": part_desc_array,
            "total_qty": total_qty_array,
            "due_date_1": due_date_1_array,
            "ma": ma_array,
            "sum_one": sum_one_array,
            "tax_pro": tax_pro_array,
            "to_do": to_do_array,
            "total_amount_one": total_amount_one_array
        ]
        
        return partDict
    }
}

