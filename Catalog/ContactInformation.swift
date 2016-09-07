//
//  Contact.swift
//  Catalog
//
//  Created by Nhat Tran on 14/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import RealmSwift

class ContactInformation {
    
    var contacts = [Contacts]()
    var alphaContacts: [String: [Contacts]]
    let alphaIndex = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
    
    init() {
        self.alphaContacts = [String: [Contacts]]()
        setupDictionary()
    }
    
    func getFromRealm() {
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let results: Results<Contacts> = realm.objects(Contacts.self)
        self.contacts = Array(results)
    }
    
    // Request contact from API
    func importContact(apiRequest: dispatch_group_t? = nil) {
        // Declare api header
        let url: String = NetworkList.Address.rawValue + NetworkList.ClientAddress.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        self.contacts.removeAll()
        // Call it
        if (apiRequest != nil) {
            dispatch_group_enter(apiRequest!)
        }
        
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                let jsonArr  = dict["_embedded"]!["item"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let client = Contacts()
                    let item = jsonArr[i]
                    client.code = String(item["client_code"]!!)
                    client.name = String(item["client_name"]!!)
                    client.email = String(item["e_mail"]!!)
                    client.phone   = String(item["phone_2"]!!)
                    client.website = String(item["web_site"]!!)
                    // Postal address
                    client.postal_address_1 = String(item["address1"]!!)
                    client.postal_address_2 = String(item["address1"]!!)
                    client.postal_city = String(item["city"]!!)
                    client.postal_postcode = String(item["postcode"]!!)
                    client.postal_state = String(item["state"]!!)
                    // Delivery address
                    client.delivery_address_1 = String(item["postal_address1"]!!)
                    client.delivery_address_2 = String(item["postal_address2"]!!)
                    client.delivery_city = String(item["postal_city"]!!)
                    client.delivery_postcode = String(item["postal_postcode"]!!)
                    client.delivery_state = String(item["p_state"]!!)
                    
                    self.contacts.append(client)
                    let name = String(client.name[0])
                    if self.alphaContacts[name] != nil {
                        self.alphaContacts[name]?.append(client)
                    } else {
                        self.alphaContacts["#"]?.append(client)
                    }
                }
                if (apiRequest != nil) {
                    dispatch_group_leave(apiRequest!)
                }
            }else {
                print(error)
                return
            }
        }
    }
    
    func setupDictionary() {
        for i in 0..<alphaIndex.count {
            self.alphaContacts[self.alphaIndex[i]] = [Contacts]()
        }
    }
    
    func sortDictionary() {
        for i in 0..<contacts.count {
            let client = contacts[i]
            let name = String(client.name[0])
            if self.alphaContacts[name] != nil {
                self.alphaContacts[name]?.append(client)
            } else {
                self.alphaContacts["#"]?.append(client)
            }
        }
    }
    
    // Import to Realm
    func downloadContact() {
        let apiRequest = dispatch_group_create()
        importContact(apiRequest)
        dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
            let cnt = self.contacts.count
            for i in 0..<cnt {
                BackgroundFunctions.insertRow(self.contacts[i])
                print("Importing \(i)/\(cnt)")
            }
        }
    }
    
}