//
//  SavedOrdersDetailViewController.swift
//  Catalog
//
//  Created by Nhat Tran on 24/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift

protocol SavedOrderDetailViewControllerDelegate {
    func setFinishedOrder(cart: CatalogueCart)
}

class SavedOrderDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SavedOrderMasterViewControllerDelegate {
    
    @IBOutlet weak var collection: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var discountlabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var delegate: SavedOrderDetailViewControllerDelegate? = nil
    var masterView: SavedOrderMasterViewController? = nil
    var cart = CatalogueCart()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = self.splitViewController {
            let navController = split.viewControllers.first as! UINavigationController
            self.masterView = navController.topViewController as? SavedOrderMasterViewController
        }
        
        self.masterView?.delegate = self
        self.collection.delegate = self
        self.collection.dataSource = self
        self.collection.tableFooterView = UIView()
    }
    
    @IBAction func unwindToSavedOrdersDetails(segue: UIStoryboardSegue) {
        if(segue.sourceViewController.isKindOfClass(CatalogueDetails))
        {
            collection.reloadData()
        }
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        if (!cart.finished) {
            try! Realm().write {
                cart.finished = true
            }
            
            if (self.delegate != nil) {
                self.delegate?.setFinishedOrder(cart)
            }
        }
    }
    
    @IBAction func goToCat(sender: UIBarButtonItem) {
        tabBarController?.selectedIndex = 1
        BackgroundFunctions.continueCustomer = cart.user
        BackgroundFunctions.switchOff = true
    }
    
    func setSavedOrderDetail(saveCart: CatalogueCart) {
        cart = saveCart
        saveButton.enabled = !cart.finished
        addButton.enabled = true
        sendButton.enabled = true
        self.collection.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.items.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // selected item
        let item = cart.items[indexPath.row]
        
        let alert = UIAlertController(title: "Item details", message: "Edit details of item", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Discount"
            //textField.text = item.ma
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Price"
            //textField.text = item.total_amount_one
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Quantity"
            //textField.text = item.total_qty
        }
        
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action: UIAlertAction!) in
            let disc = alert.textFields![0]
            let price = alert.textFields![1]
            let qty = alert.textFields![2]
            try! Realm().write {
                
                if (!(disc.text?.isEmpty)!) {
                    item.ma = disc.text!
                } else {
                    disc.text = item.ma
                }
                
                if (!(price.text?.isEmpty)!) {
                    item.total_amount_one = price.text!
                } else {
                    price.text = item.total_amount_one
                }
                
                if (!(qty.text?.isEmpty)!) {
                    item.total_qty = qty.text!
                } else {
                    qty.text = item.total_qty
                }

                item.sum_one = String(Double(qty.text!)! * Double(price.text!)!)
                
            }
            self.totalLabel.text = item.sum_one
            self.collection.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SavedCartDetailCell", forIndexPath: indexPath) as! SavedOrderDetailCell
        
        if (cart.items.count > 0) {
            let code = cart.items[indexPath.row].code
            let realm = try! Realm()
            let result = realm.objects(Materials.self).filter("code = '\(code)'").first
            cell.codeLabel.text = code
            cell.descLabel.text = cart.items[indexPath.row].desc
            cell.stockLabel.text = String((result?.stock)!)
            cell.qtyLabel.text = cart.items[indexPath.row].total_qty
            cell.totalPriceLabel.text = cart.items[indexPath.row].sum_one
            cell.discountLabel.text = cart.items[indexPath.row].ma
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let deletedItem = cart.items[indexPath.row].sum_one
            BackgroundFunctions.mitigrateRealm()
            let realm = try! Realm()
            try! realm.write {
                cart.cart_total_price -= Double(deletedItem)!
                //totalPriceLabel.text = String(cartList.cart_total_price)
                cart.items.removeAtIndex(indexPath.row)
            }
            collection.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
}
