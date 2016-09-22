//
//  DownloadViewController.swift
//  Catalog
//
//  Created by Nhat Tran on 2/09/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController {
    
    @IBOutlet weak var matProgress: UIProgressView!
    @IBOutlet weak var imagesProgress: UIProgressView!
    @IBOutlet weak var salesProgress: UIProgressView!
    @IBOutlet weak var contactProgress: UIProgressView!
    @IBOutlet weak var imagesLabel: UILabel!
    
    var downloadManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        downloadManager.delegate = self
        imagesProgress.progress = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startDownloading() {
        
        // Sync Images
        downloadImages()
        
        // Sync Materials
        //syncMaterials()
        
        // Sync Contacts
        //syncContacts()
    }
    
    func downloadImages() {
        let urlStrings = [
            "http://192.168.222.114:8000/images/images.zip"
        ]
        let urls = urlStrings.map { NSURL(string: $0)! }
        
        for url in urls {
            downloadManager.addDownload(url)
        }
        
        // Wait for all dispatch
        dispatch_group_notify(downloadManager.api, dispatch_get_main_queue()) {
            print("Downloading finished")
        }
    }
    
    func syncMaterials() {
        
    }
    
    func syncContacts() {
        let contacts = ContactInformation()
        contacts.downloadContact()
    }
}

extension DownloadViewController: NetworkManagerDelegate {
    func setProgressViewController(downloadPercentage: Float) {
        imagesProgress.progress = downloadPercentage
        imagesLabel.text = String(format: "%.0f", (downloadPercentage * 100)) + "%"
    }
}

extension DownloadViewController: SalesOrderImportAPIDelegate {
    func setSalesOrderProgress(importPercentage: Float) {
        salesProgress.progress = importPercentage
    }
}

extension DownloadViewController: ContactsImportAPIDelegate {
    func contactsProgress(importPercentage: Float) {
        contactProgress.progress = importPercentage
    }
}