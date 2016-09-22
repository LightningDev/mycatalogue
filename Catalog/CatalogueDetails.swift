//
//  CatalogueDetails.swift
//  Catalog
//
//  Created by Nhat Tran on 20/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift
import ActionSheetPicker_3_0

protocol CatalogueDetailsDelegate {
    func loadCatalogueDetails(controller: CatalogueDetails)
}

class CatalogueDetails: UIViewController {
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var qtyTextfield: UITextField!
    @IBOutlet weak var discountTextfield: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var moreInfoTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var clientCodeTextField: UITextField!
    @IBOutlet weak var uiPickerView: UIView!
    @IBOutlet weak var addToCartButton: UIButton!
    
    // Offline - unstable
    let checkOnline = false
    
    var delegate: CatalogueDetailsDelegate? = nil
    var currentContact = Contacts()
    var contactList = ContactInformation()
    var selectedCode: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.delegate != nil) {
            self.delegate?.loadCatalogueDetails(self)
        }
        self.moreInfoTextView.delegate = self
        self.moreInfoTextView.text = "Additional Info"
        self.moreInfoTextView.textColor = UIColor.lightGrayColor()
        
        self.clientCodeTextField.text = BackgroundFunctions.getdefaultClient().code
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func increaseQty(sender: UIButton) {
        let value: Int = Int(qtyTextfield.text!)! + 1
        qtyTextfield.text = String(value)
        totalPriceLabel.text = String(calculateTotalPrice(value))
    }
    
    @IBAction func decreaseQty(sender: UIButton) {
        var value: Int = Int(qtyTextfield.text!)!
        if (value > 0) {
            value -= 1
        }
        qtyTextfield.text = String(value)
        totalPriceLabel.text = String(calculateTotalPrice(value))
    }
    
    @IBAction func increaseDiscount(sender: UIButton) {
        let value: Int = Int(discountTextfield.text!)! + 1
        discountTextfield.text = String(value)
        //totalPriceLabel.text = String(calculateTotalPrice(value))
    }
    
    @IBAction func decreaseDiscount(sender: UIButton) {
        var value: Int = Int(discountTextfield.text!)!
        if (value > 0) {
            value -= 1
        }
        discountTextfield.text = String(value)
        //totalPriceLabel.text = String(calculateTotalPrice(value))
    }
    
    // Do a shitty job, my memory is overloaded at this step. DND mode
    @IBAction func getClientCode(sender: UIButton) {
        if (checkOnline) {
            let apiRequest = dispatch_group_create()
            contactList.importContact(apiRequest)
            dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                self.pickerViewShow(self.contactList.toCodeArray(), sender: sender)
            }
        } else {
            readContactLocal()
            pickerViewShow(contactList.toCodeArray(), sender: sender)
        }
    }
    
    @IBAction func placeOrder(sender: UIButton) {
        
        if (addToCartButton.titleLabel?.text != "Continue") {
            addToCart()
        } else {
            self.performSegueWithIdentifier("unwindToCatalogue", sender: self)
        }
        
    }
    
    func pickerViewShow(string: [String], sender: AnyObject?) {
        //print(string)
        ActionSheetMultipleStringPicker.showPickerWithTitle("Pick a group", rows: [
            string
            ], initialSelection: [1], doneBlock: {
                picker, values, indexes in
                print(indexes)
                return
            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender )
    }
    
    func addToCart() {
        
        let order = Parts()
        order.code = codeLabel.text!
        order.desc = descriptionTextView.text
        order.total_qty = qtyTextfield.text!
        order.total_amount_one = priceLabel.text!
        order.sum_one = totalPriceLabel.text!
        order.ma = discountTextfield.text!
        
        // Read from realm
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let user = clientCodeTextField.text
        let query = "user = '\(user!)'"
        let results: Results<CatalogueCart> = realm.objects(CatalogueCart.self).filter(query)
        let catalogueCart = CatalogueCart()
        var catalogueCarts = [CatalogueCart]()
        catalogueCarts = Array(results)
        
        let cnt = catalogueCarts.count
        
        // Update stock of material
        try! realm.write {
            let result = realm.objects(Materials.self).filter("code = '\(codeLabel.text!)'").first
            result!.stock -= Double(qtyTextfield.text!)!
        }
        
        if (cnt > 0) {
            do {
                try! realm.write {
                    // Check the order
                    var checkDuplicate: Bool = false
                    for i in 0..<catalogueCarts[0].items.count {
                        let checkItem = catalogueCarts[0].items[i]
                        if (checkItem.code == order.code) {
                            checkDuplicate = true
                            let total_qty = Double(catalogueCarts[0].items[i].total_qty)! + Double(order.total_qty)!
                            let total = Double(catalogueCarts[0].items[i].sum_one)! + Double(order.sum_one)!
                            catalogueCarts[0].items[i].total_qty = String(total_qty)
                            catalogueCarts[0].items[i].sum_one = String(total)
                            catalogueCarts[0].cart_total_price += Double(order.sum_one)!
                        }
                    }
                    if (!checkDuplicate) {
                        realm.add(order, update: true)
                        catalogueCarts[0].items.append(order)
                        catalogueCarts[0].cart_total_price = catalogueCarts[0].cart_total_price + Double(totalPriceLabel.text!)!
                    }
                }
                addToCartButton.setTitle("Continue", forState: .Normal)
            } catch let error as NSError {
                print(error)
            }
        } else {
            catalogueCart.code = "\(user!)_\(cnt+1)"
            catalogueCart.cart_total_price = Double(totalPriceLabel.text!)!
            catalogueCart.finished = false
            catalogueCart.user = clientCodeTextField.text!
            catalogueCart.created_date = NSDate()
            
            do {
                try! realm.write {
                    realm.add(catalogueCart)
                    realm.add(order, update: true)
                    catalogueCart.items.append(order)
                }
                addToCartButton.setTitle("Continue", forState: .Normal)
            } catch let error as NSError {
                print(error)
            }
        }
        
    }
    
    @IBAction func goToCheckOut(sender: UIButton) {
        
    }
    
    @IBAction func goBackCatalogue(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToCatalogue", sender: self)
    }
    
    @IBAction func goBackSavedOrderDetails(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToSavedOrdersDetails", sender: self)
    }
    
    @IBAction func doneButtonClicked(sender: UIButton) {
        clientCodeTextField.text = contactList.contacts[selectedCode].code
        hideUIPickerView(true)
    }
    
    @IBAction func cancelButtonClicked(sender: UIButton) {
        hideUIPickerView(true)
    }
    
    func calculateTotalPrice(qty: Int) -> Double {
        let price: Double = Double(priceLabel.text!)!
        return (price * Double(qty))
    }
    
    func hideUIPickerView(value: Bool) {
        uiPickerView.hidden = value
    }
    
    func readContactLocal() {
        contactList.getFromRealm()
    }
    
}

extension CatalogueDetails: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.grayColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Additional Info"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}

// PickerView
extension CatalogueDetails: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contactList.contacts.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return contactList.contacts[row].code
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //clientCodeTextField.text = contactList.contacts[row].code
        self.selectedCode = row
    }
}
