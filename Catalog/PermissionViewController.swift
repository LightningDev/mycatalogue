//
//  PermissionViewController.swift
//  Catalog
//
//  Created by Nhat Tran on 26/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift

protocol PermissionViewControllerDelegate {
    func preAccountInformation(controller: PermissionViewController)
}

class PermissionViewController: UIViewController {
    
    // UIView
    @IBOutlet weak var contactsView: UIView!
    @IBOutlet weak var catalogueView: UIView!
    @IBOutlet weak var salesOrdersView: UIView!
    @IBOutlet weak var savedOrdersView: UIView!
    
    @IBOutlet weak var finishButton: UIButton!
    
    @IBOutlet weak var contactsSwitch: UISwitch!
    @IBOutlet weak var catalogueSwitch: UISwitch!
    @IBOutlet weak var salesOrdersSwitch: UISwitch!
    @IBOutlet weak var savedOrdersSwitch: UISwitch!
    
    @IBAction func finishButtonClicked() {
        let conPer = contactsSwitch.on.toInt()
        let catPer = catalogueSwitch.on.toInt()
        let salePer = salesOrdersSwitch.on.toInt()
        let savePer = savedOrdersSwitch.on.toInt()
        let permission = "\(conPer)\(catPer)\(salePer)\(savePer)"
        
        employee.permission = permission
        
        BackgroundFunctions.insertRow(employee)
        
        BackgroundFunctions.setCurrentUser(employee)
    }
    
    var delegate: PermissionViewControllerDelegate? = nil
    var employee = Employees()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        if (self.delegate != nil) {
            self.delegate?.preAccountInformation(self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackToNewAccount(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToNewAccount", sender: self)
    }
    
    func setupLayout() {
        
        // Form border
        //        mainView.layer.borderColor = UIColor.lightGrayColor().CGColor
        //        mainView.layer.cornerRadius = 5
        //        mainView.layer.borderWidth = 1
        
        // View bottom border
        let contactsViewBorder: CALayer = createBottomBorderUIView(contactsView, lineWidth: contactsView.frame.size.width-20)
        contactsView.layer.addSublayer(contactsViewBorder)
        
        let catalogueViewBorder: CALayer = createBottomBorderUIView(catalogueView, lineWidth: catalogueView.frame.size.width-20)
        catalogueView.layer.addSublayer(catalogueViewBorder)
        
        let salesOrdersViewBorder: CALayer = createBottomBorderUIView(salesOrdersView, lineWidth: salesOrdersView.frame.size.width-20)
        salesOrdersView.layer.addSublayer(salesOrdersViewBorder)
        
        let savedOrdersViewBorder: CALayer = createBottomBorderUIView(savedOrdersView, lineWidth: savedOrdersView.frame.size.width-20)
        savedOrdersView.layer.addSublayer(savedOrdersViewBorder)
        
        // Button
        finishButton.layer.borderColor = UIColor.whiteColor().CGColor
        finishButton.layer.borderWidth = 1
        finishButton.layer.cornerRadius = 10
        
    }
    
    func createBorder(frameX: CGFloat, frameY: CGFloat, width: CGFloat, height: CGFloat) -> CALayer {
        let border: CALayer = CALayer()
        border.backgroundColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRectMake(frameX, frameY, width, height)
        return border
    }
    
    func createBottomBorderUIView(yourView: UIView, lineWidth: CGFloat) -> CALayer {
        let height = yourView.frame.size.height
        let yourLayer = createBorder(10.0, frameY: height - 1, width: lineWidth, height: 1.0)
        return yourLayer
    }
}
