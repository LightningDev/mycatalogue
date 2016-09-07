//
//  LoginViewController.swift
//  Catalog
//
//  Created by Nhat Tran on 26/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    // UIView
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var rememberMe: UISwitch!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        login()
    }
    
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
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "segueToMainMenu" {
            return login()
        }
        return true
    }
    
    func login() -> Bool {
        BackgroundFunctions.mitigrateRealm()
        let realm = try! Realm()
        let username = usernameField.text
        let password = passwordField.text
        let results = realm.objects(Employees.self).filter("username = '\(username!)' AND password = '\(password!)'")
        
        if (results.count == 0) {
            errorLabel.text = "Please set up a new acccount"
            errorLabel.hidden = false
        } else {
            errorLabel.hidden = true
            BackgroundFunctions.setCurrentUser(results[0])
        }
        
        return errorLabel.hidden
    }
    
    func setupFirstTime() {
        
    }
    
    func setupLayout() {
        
        // Form border
//        mainView.layer.borderColor = UIColor.lightGrayColor().CGColor
//        mainView.layer.cornerRadius = 5
//        mainView.layer.borderWidth = 1
        
        usernameField.attributedPlaceholder = NSAttributedString(string:"Username",
                                                               attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordField.attributedPlaceholder = NSAttributedString(string:"Password",
                                                                 attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // View bottom border
        let userNameBorder: CALayer = createBottomBorderUIView(usernameView, lineWidth: mainView.frame.size.width-20)
        usernameView.layer.addSublayer(userNameBorder)
        
        let passwordBorder: CALayer = createBottomBorderUIView(passwordView, lineWidth: mainView.frame.size.width-20)
        passwordView.layer.addSublayer(passwordBorder)
        
        // Button
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.borderWidth = 1
        loginButton.layer.cornerRadius = 10
        
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
