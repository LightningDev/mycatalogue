//
//  ContactList.swift
//  Catalog
//
//  Created by Nhat Tran on 13/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import UIKit

protocol ContactListDelegate {
    func setContactDetails(contact: Contacts)
}

class ContactList: UIViewController {
    
    let alphaIndex = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
    let contactList = ContactInformation()
    var contactDetail: ContactDetails? = nil
    @IBOutlet weak var tableView: UITableView!
    var delegate: ContactListDelegate? = nil
    
    // Online - unstable
    let checkOnline = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func refreshContact() {
        if (checkOnline) {
            let apiRequest = dispatch_group_create()
            self.contactList.importContact(apiRequest)
            dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        } else {
            readContactsLocal()
        }

    }
    
    func readContactsLocal() {
        contactList.getFromRealm()
        contactList.sortDictionary()
        self.tableView.reloadData()
    }
    
    @IBAction func goBackHome(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToHome", sender: self)
    }
}

extension ContactList: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let section = indexPath.section
        if (self.delegate != nil) {
            let itemContacts = self.contactList.alphaContacts[self.alphaIndex[section]]
            self.delegate?.setContactDetails(itemContacts![row])
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return self.alphaIndex
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ContactCell
        ///let name = self.contactList.contacts[indexPath.row].name

        if (self.contactList.contacts.count > 0) {
            let itemContacts = self.contactList.alphaContacts[self.alphaIndex[indexPath.section]]
            cell.nameLabel.text = itemContacts![indexPath.row].name
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 27
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.contactList.alphaContacts[self.alphaIndex[section]]?.count)!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.alphaIndex[section]
    }
}

