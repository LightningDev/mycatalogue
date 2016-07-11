//
//  MainMenu.swift
//  Catalog
//
//  Created by Nhat Tran on 8/06/2016.
//  Copyright (c) 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift

class MainMenu: UIViewController {
    
    // Properties
    @IBOutlet var syncButton: UIBarButtonItem!
    var numDownloads: Int = 0
    var numItems: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Actions
    @IBAction func accountsBtn(sender: UIButton) {
        
        
    }
    
    @IBAction func catalogueBtn(sender: UIButton) {
        
    }
    
    @IBAction func salesBtn(sender: UIButton) {
        
        
    }
    
    @IBAction func syncBtn(sender: UIBarButtonItem) {
        
        // download database
        BackgroundFunctions.cleanDatabase()
        //loadMaterialGroups()
        
        let catalogue = Catalogue()
        catalogue.downloadFromServer()
        
    }
    
    // Functions
    
    // Get material groups from server
    func loadMaterialGroups() {
        let group = dispatch_group_create()
        let url: String = "http://192.168.222.113:8000/api/matgroup"
        let username = "OPTO"
        let password = "opto"
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        dispatch_group_enter(group)
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                
                let jsonArr  = dict["_embedded"]!["item"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                self.numItems = jsonCnt
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    let matGroup = MaterialGroups()
                    matGroup.code = String(item["code"]!!)
                    matGroup.desc = String(item["description"]!!)
                    //self.loadCatalogueList(matGroup)
                }
                self.numItems = jsonCnt
                print("all downloaded")
                dispatch_group_leave(group)
            }else {
                print(error)
                return
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            print("request done \(self.numItems)")
        }
    }
    
    func loadCatalogueList(matGroup: MaterialGroups) {
        let url: String = "http://192.168.222.113:8000/api/matgroup/" + matGroup.code
        let username = "OPTO"
        let password = "opto"
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!, checkCode: matGroup.code)
                if (dict.count == 0 ) {
                    print("Ignored \(matGroup.code) because of unexpected characters")
                    return
                }
                let jsonArr  = dict["_embedded"]!["materials"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    let matItem = Materials() 
                    matItem.code = String(item["material_code"]!!)
                    matItem.desc = String(item["description"]!!)
                    matItem.path = String(item["path"]!!)
                    matItem.stock = Double(String(item["stock"]!!))!
                    matGroup.materials.append(matItem)
                    BackgroundFunctions.insertRow(matItem)
                }
                BackgroundFunctions.insertRow(matGroup)
                print("Downloaded \(matGroup.code)")
                //BackgroundFunctions.modifyRow(matGroup)
            }else {
                print(error)
                return
            }
        }
    }
    

    
}

