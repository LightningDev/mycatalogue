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
    @IBOutlet var accountButton: UIButton!
    @IBOutlet var saleButton: UIButton!
    @IBOutlet var catalogueButton: UIButton!
    @IBOutlet var savedButton: UIButton!
    
    var numDownloads: Int = 0
    var numItems: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User account
        let userAccount = BackgroundFunctions.getCurrentUser()
        let permission = userAccount.permission
        
        accountButton.enabled = String(permission[Permission.CONTACTS.rawValue]).toBool()
        catalogueButton.enabled = String(permission[Permission.CATALOGUE.rawValue]).toBool()
        saleButton.enabled = String(permission[Permission.SALES_ORDERS.rawValue]).toBool()
        savedButton.enabled = String(permission[Permission.SAVED_ORDERS.rawValue]).toBool()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Actions
    @IBAction func unwindToThis(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func syncBtn(sender: UIBarButtonItem) {
        
        // download database
        BackgroundFunctions.cleanDatabase()
        //loadMaterialGroups()
        
//        // Catalogue
        let catalogue = Catalogue()
        catalogue.downloadFromServer()
        //catalogue.downloadSubMaterialGroup()
//
//        // Contact
//        let contacts = ContactInformation()
//        contacts.downloadContact()
//        
//        let downloadManager = DownloadManager()
//        let api = dispatch_group_create()
//        downloadManager.downloadAllCatalogue(api)
//        dispatch_group_notify(api, dispatch_get_main_queue()) {
//            downloadManager.importMaterialToRealm()
//        }
        
        // Sale order
        let sales = SalesOrders()
        sales.downloadSalesOrder()
        
        // Contact
        let contacts = ContactInformation()
        contacts.downloadContact()
        
        
    }
    
    @IBAction func loginButton(sender: UIBarButtonItem) {

    }
    
    
}

