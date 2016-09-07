//
//  CheckoutController.swift
//  Catalog
//
//  Created by Nhat Tran on 22/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift

protocol CheckOutControllerDelegate {
    func lostCustomerDetails(controller: CheckoutController)
}

class CheckoutController: UIViewController {
    
    // UIView
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var employeeView: UIView!
    @IBOutlet weak var clientOrderNoView: UIView!
    @IBOutlet weak var address1View: UIView!
    @IBOutlet weak var address2View: UIView!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var postcodeView: UIView!
    @IBOutlet weak var countryView: UIView!
    
    // Textfield
    @IBOutlet weak var employeeNumberField: UITextField!
    @IBOutlet weak var clientOrderNoField: UITextField!
    @IBOutlet weak var address1Field: UITextField!
    @IBOutlet weak var address2Field: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var postcodeField: UITextField!
    @IBOutlet weak var countryField: UITextField!
    
    // Button
    @IBOutlet weak var addButton: UIButton!
    
    var delegate: CheckOutControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        
        if (self.delegate != nil) {
            self.delegate?.lostCustomerDetails(self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackCart(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToCart", sender: self)
    }
    
    func setupLayout() {
        
        // Form border
        mainView.layer.borderColor = UIColor.lightGrayColor().CGColor
        mainView.layer.cornerRadius = 5
        mainView.layer.borderWidth = 1
        
        
        // View bottom border
        let empBorder: CALayer = createBottomBorderUIView(employeeView, lineWidth: mainView.frame.size.width)
        employeeView.layer.addSublayer(empBorder)
        
        let clientOrderNoBorder: CALayer = createBottomBorderUIView(clientOrderNoView, lineWidth: mainView.frame.size.width)
        clientOrderNoView.layer.addSublayer(clientOrderNoBorder)
        
        let address1ViewBorder: CALayer = createBottomBorderUIView(address1View, lineWidth: mainView.frame.size.width)
        address1View.layer.addSublayer(address1ViewBorder)
        
        let address2ViewBorder: CALayer = createBottomBorderUIView(address2View, lineWidth: mainView.frame.size.width)
        address2View.layer.addSublayer(address2ViewBorder)
        
        let cityViewBorder: CALayer = createBottomBorderUIView(cityView, lineWidth: mainView.frame.size.width)
        cityView.layer.addSublayer(cityViewBorder)
        
        let stateViewBorder: CALayer = createBottomBorderUIView(stateView, lineWidth: mainView.frame.size.width)
        stateView.layer.addSublayer(stateViewBorder)
        
        let postcodeViewBorder: CALayer = createBottomBorderUIView(postcodeView, lineWidth: mainView.frame.size.width)
        postcodeView.layer.addSublayer(postcodeViewBorder)
        
        // Button
        addButton.layer.borderColor = addButton.layer.backgroundColor
        addButton.layer.cornerRadius = 70
        
    }
    
    func createBorder(frameX: CGFloat, frameY: CGFloat, width: CGFloat, height: CGFloat) -> CALayer {
        let border: CALayer = CALayer()
        border.backgroundColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRectMake(frameX, frameY, width, height)
        return border
    }
    
    func createBottomBorderUIView(yourView: UIView, lineWidth: CGFloat) -> CALayer {
        let height = yourView.frame.size.height
        let yourLayer = createBorder(0.0, frameY: height - 1, width: lineWidth, height: 1.0)
        return yourLayer
    }
    
    @IBAction func postTheOrder() {
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let results = realm.objects(CatalogueCart.self).filter("user == 'admin'")
        
    }
}
