//
//  SavedCart.swift
//  Catalog
//
//  Created by Nhat Tran on 25/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import RealmSwift

class SavedCart {
    
    var savedCartArrayNonOrder = [CatalogueCart]()
    var savedCartDictionary = [String: [CatalogueCart]]()
    var savedCartHeaderArray = [String]()
    
    func getSavedCart() {
        savedCartDictionary.removeAll()
        savedCartHeaderArray.removeAll()
        savedCartArrayNonOrder.removeAll()
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let results: Results<CatalogueCart> = realm.objects(CatalogueCart.self)
        let savedCart = Array(results)
        let savedCartCnt = savedCart.count
        for i in 0..<savedCartCnt {
            let _savedCart = savedCart[i]
            savedCartArrayNonOrder.append(_savedCart)
            let name = _savedCart.user
            if (savedCartDictionary[name] == nil) {
                savedCartHeaderArray.append(name)
                savedCartDictionary[name] = [CatalogueCart]()
            }
        }
        setUpDictionary()
    }
    
    func setUpDictionary() {
        for i in 0..<self.savedCartArrayNonOrder.count {
            let item = self.savedCartArrayNonOrder[i]
            self.savedCartDictionary[item.user]?.append(item)
        }
    }
    
}