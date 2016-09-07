//
//  NewAccountController.swift
//  Catalog
//
//  Created by Nhat Tran on 26/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RMPickerViewController

class NewAccountController: UIViewController {
    
    // UIView
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var employeeCode: UIView!
    @IBOutlet weak var employeeName: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var employeeField: UITextField!
    @IBOutlet weak var employeenameField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func unwindToNewAccount(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func employeeCodeButtonClicked(sender: UIButton) {
        let apiGroup = dispatch_group_create()
        employees.getEmployeesFromServer(apiGroup)
        dispatch_group_notify(apiGroup, dispatch_get_main_queue()) {
            self.openPickerViewController()
        }
        
    }
    
    func checkForm() -> Bool {
        let checkUsername = (usernameField.text?.isEmpty)!
        let checkPassword = (passwordField.text?.isEmpty)!
        let checkEmpcode = (employeeField.text?.isEmpty)!
        let checkEmpname = (employeenameField.text?.isEmpty)!
        
        let check = (checkUsername || checkPassword || checkEmpname || checkEmpcode)
        
        return (check) ? false : true
    }
    
    var employees = EmployeesInformation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "newAccountToPermission") {
            let svc = segue.destinationViewController as! PermissionViewController
            svc.delegate = self
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "newAccountToPermission" {
            let check = checkForm()
            if (!check) {
                errorLabel.hidden = false
            } else {
                errorLabel.hidden = true
            }
            return check
        }
        return true
    }
    
    func openPickerViewController() {
        
        // Select color of picker view
        let style = RMActionControllerStyle.White
        
        // Handling select button
        let selectAction = RMAction(title: "Select", style: RMActionStyle.Done) { controller in
            if let pickerController = controller as? RMPickerViewController {
                let selectedRows = NSMutableArray();
                
                for i in 0..<pickerController.picker.numberOfComponents  {
                    selectedRows.addObject(pickerController.picker.selectedRowInComponent(i));
                }
                
                //print("Successfully selected rows: ", selectedRows);
                let selectedRow = (selectedRows[0] as! Int)
                self.employeeField.text = self.employees.employees[selectedRow].code
                self.employeenameField.text = self.employees.employees[selectedRow].name
            }
        }
        
        let cancelAction = RMAction(title: "Cancel", style: RMActionStyle.Cancel) { _ in
            print("Row selection was canceled")
        }
        
        let actionController = RMPickerViewController(style: style, title: "Employee List", message: "Please select your corresponding name.\nPlease choose a name and press 'Select' or 'Cancel'.", selectAction: selectAction, andCancelAction: cancelAction)!;
        
        //You can enable or disable blur, bouncing and motion effects
        actionController.disableBouncingEffects = false
        actionController.disableMotionEffects = false
        actionController.disableBlurEffects = false
        
        actionController.picker.delegate = self;
        actionController.picker.dataSource = self;
        actionController.picker.reloadAllComponents()
        
        //Now just present the date selection controller using the standard iOS presentation method
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    func setupLayout() {
        
        // Form border
        //        mainView.layer.borderColor = UIColor.lightGrayColor().CGColor
        //        mainView.layer.cornerRadius = 5
        //        mainView.layer.borderWidth = 1
        
        employeeField.attributedPlaceholder = NSAttributedString(string:"Employee Code",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        employeenameField.attributedPlaceholder = NSAttributedString(string:"Employee Name",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        usernameField.attributedPlaceholder = NSAttributedString(string:"Username",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // View bottom border
        let userNameBorder: CALayer = createBottomBorderUIView(usernameView, lineWidth: usernameView.frame.size.width-20)
        usernameView.layer.addSublayer(userNameBorder)
        
        let passwordBorder: CALayer = createBottomBorderUIView(passwordView, lineWidth: passwordView.frame.size.width-20)
        passwordView.layer.addSublayer(passwordBorder)
        
        let employeeCodeBorder: CALayer = createBottomBorderUIView(employeeCode, lineWidth: employeeCode.frame.size.width-20)
        employeeCode.layer.addSublayer(employeeCodeBorder)
        
        let employeeNameBorder: CALayer = createBottomBorderUIView(employeeName, lineWidth: employeeName.frame.size.width-20)
        employeeName.layer.addSublayer(employeeNameBorder)
        
        // Button
        nextButton.layer.borderColor = UIColor.whiteColor().CGColor
        nextButton.layer.borderWidth = 1
        nextButton.layer.cornerRadius = 10
        
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

extension NewAccountController: PermissionViewControllerDelegate {
    func preAccountInformation(controller: PermissionViewController) {
        let employee = Employees()
        employee.code = employeeField.text!
        employee.name = employeenameField.text!
        employee.username = usernameField.text!
        employee.password = passwordField.text!
        
        controller.employee = employee
    }
}

extension NewAccountController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: UIPickerView Delegates
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return employees.employees.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return employees.employees[row].name
    }
}