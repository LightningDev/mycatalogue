//
//  ContactDetails.swift
//  Catalog
//
//  Created by Nhat Tran on 14/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class ContactDetails: UIViewController {
    
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactCode: UILabel!
    @IBOutlet weak var contactType: UILabel!
    @IBOutlet weak var contactPhone: UITextField!
    @IBOutlet weak var contactEmail: UITextField!
    @IBOutlet weak var contactWebsite: UITextField!
    
    var contactList: ContactList? = nil
    var contact: Contacts!
    
    @IBAction func setContactDefault(sender: UIBarButtonItem) {
        BackgroundFunctions.setdefaultClient(self.contact)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = self.splitViewController {
            let navController = split.viewControllers.first as! UINavigationController
            self.contactList = navController.topViewController as? ContactList
        }
        self.contactList?.delegate = self
    }
    
    func configureView() {
        
    }
    
}

extension ContactDetails: ContactListDelegate {
    func setContactDetails(contact: Contacts) {
        self.contactName.text = contact.name
        self.contactCode.text = contact.code
        self.contactEmail.text = contact.email
        self.contactPhone.text = contact.phone
        self.contactWebsite.text = contact.website
        self.contact = contact
    }
}
