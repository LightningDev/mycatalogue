//
//  CartController.swift
//  Catalog
//
//  Created by Nhat Tran on 22/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift

class CartController: UIViewController {
    
    var realm: AnyObject?
    let user = "admin"
    var cartList = CatalogueCart()
    var contactList = ContactInformation()
    var existedCustomerCart = [Contacts]()
    var selectedCode = 0
    var numberOfCart: Int {
        get {
            return cartList.items.count
        }
    }
    var currentContact: Contacts {
        return existedCustomerCart[selectedCode]
    }
    
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var processButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var uiPickerView: UIView!
    
    @IBOutlet weak var customerPickerView: UIPickerView!
    
    // Offline - unstable
    let checkOnline = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup color button
        processButton.layer.borderColor = processButton.backgroundColor?.CGColor
        cancelButton.layer.borderColor = processButton.backgroundColor?.CGColor
        processButton.layer.cornerRadius = 50
        cancelButton.layer.cornerRadius = 50
        
        self.cartTableView.delegate = self
        self.cartTableView.dataSource = self
        hideUIPickerView(true)
        BackgroundFunctions.mitigrateRealm()
        realm = try! Realm()
        self.customerPickerView.dataSource = self
        self.customerPickerView.delegate = self
//        readCartTable()
//        self.cartTableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func customerButtonClicked(sender: UIBarButtonItem) {
        self.existedCustomerCart.removeAll()
        if (checkOnline) {
            let apiRequest = dispatch_group_create()
            contactList.importContact(apiRequest)
            dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                self.checkCartContactExists()
            }
        } else {
            readContactLocal()
        }

    }
    
    @IBAction func doneButtonClicked(sender: UIButton) {
        readCartTable(self.existedCustomerCart[selectedCode].code)
        cartTableView.reloadData()
        hideUIPickerView(true)
    }
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        hideUIPickerView(true)
    }
    
    @IBAction func goBackHome(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToHome", sender: self)
    }

    @IBAction func unwindToThis(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func cancelOrderButton(sender: UIButton) {
        if (cartTableView.numberOfRowsInSection(0) > 0) {
            let alert = UIAlertController(title: "Warning", message: "Do you want to cancel this order", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                BackgroundFunctions.deleteRow(self.cartList)
                self.cartList = CatalogueCart()
                self.cartTableView.reloadData()
                self.totalPriceLabel.text = "0"
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            
        }
  
    }
    
    @IBAction func saveCart(sender: UIButton) {
        try! (realm as? Realm)!.write {
            cartList.finished = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CartToCheckoutSegue") {
            let svc = segue.destinationViewController as! UINavigationController
            let controller = svc.topViewController as! CheckoutController
            controller.delegate = self
        }
    }
    
    func readContactLocal() {
        contactList.getFromRealm()
        self.checkCartContactExists()
    }
    
    func checkCartContactExists() {
        let results: Results<CatalogueCart> = (realm as? Realm)!.objects(CatalogueCart.self)
        let tempCart = Array(results)
        let tempCartCnt = tempCart.count
        for i in 0..<tempCartCnt {
            for j in 0..<contactList.contacts.count {
                let contact = contactList.contacts[j]
                if (contact.code == tempCart[i].user) {
                    existedCustomerCart.append(contact)
                }
            }
        }
        
        if (self.existedCustomerCart.count > 0) {
            self.hideUIPickerView(false)
            self.customerPickerView.reloadAllComponents()
        } else {
            let alert = UIAlertController(title: "Warning", message: "No carts found from customers", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func readCartTable(user: String) {
        let results = (realm as? Realm)!.objects(CatalogueCart.self).filter("user = '\(user)'")
        var catalogueCarts = [CatalogueCart]()
        catalogueCarts = Array(results)
        
        let _finished = 0
        
//        for i in 0..<catalogueCarts.count {
//            if (!catalogueCarts[i].finished) {
//                _finished = i
//                break
//            }
//        }
        
        if (catalogueCarts[_finished].items.count > 0) {
            cartList = catalogueCarts[_finished]
            totalPriceLabel.text = String(catalogueCarts[_finished].cart_total_price)
        } else {
            let alert = UIAlertController(title: "Warning", message: "Empty cart in this customer", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func hideUIPickerView(value: Bool) {
        uiPickerView.hidden = value
    }
}

// TableView
extension CartController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CartCell", forIndexPath: indexPath) as! CartCell
        if (cartList.items.count > 0) {
            cell.itemCode.text = cartList.items[indexPath.row].code
            cell.itemDesc.text = cartList.items[indexPath.row].desc
            cell.itemQuantity.text = cartList.items[indexPath.row].total_qty
            cell.itemTotalPrice.text = cartList.items[indexPath.row].sum_one
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCart
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let deletedItem = cartList.items[indexPath.row].sum_one
            BackgroundFunctions.mitigrateRealm()
            let realm = try! Realm()
            try! realm.write {
                cartList.cart_total_price -= Double(deletedItem)!
                totalPriceLabel.text = String(cartList.cart_total_price)
                cartList.items.removeAtIndex(indexPath.row)
            }
            cartTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}

// PickerView
extension CartController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return existedCustomerCart.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return existedCustomerCart[row].code
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCode = row
    }
    
}

extension CartController: CheckOutControllerDelegate {
    func lostCustomerDetails(controller: CheckoutController) {
        controller.address1Field.text = currentContact.delivery_address_1
        controller.address2Field.text = currentContact.delivery_address_2
        controller.cityField.text = currentContact.delivery_city
        controller.postcodeField.text = currentContact.delivery_postcode
        controller.countryField.text = currentContact.postal_country
    }
}