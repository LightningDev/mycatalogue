//
//  SavedOrdersMasterViewController.swift
//  Catalog
//
//  Created by Nhat Tran on 24/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

protocol SavedOrderMasterViewControllerDelegate {
    func setSavedOrderDetail(savedCart: CatalogueCart)
}

class SavedOrderMasterViewController: UITableViewController {
    
    // Properties
    let savedCart = SavedCart()
    var delegate: SavedOrderMasterViewControllerDelegate? = nil
    var detailView: SavedOrderDetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let split = self.splitViewController {
            let navController = split.viewControllers.first as! UINavigationController
            self.detailView = navController.topViewController as? SavedOrderDetailViewController
        }
        
        self.detailView?.delegate = self
    }
    
    override func didReceiveMemoryWarning(  ) {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let section = indexPath.section
        let sectionHeader = savedCart.savedCartHeaderArray[section]
        let item = savedCart.savedCartDictionary[sectionHeader]
        if (self.delegate != nil) {
            self.delegate?.setSavedOrderDetail(item![row])
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SavedCartCell", forIndexPath: indexPath) as! SavedOrderCell
        
        if (savedCart.savedCartArrayNonOrder.count > 0) {
            let sectionHeader = savedCart.savedCartHeaderArray[indexPath.section]
            let itemInThis = savedCart.savedCartDictionary[sectionHeader]
            cell.orderCodeLabel.text = itemInThis![indexPath.row].code
            if (itemInThis![indexPath.row].finished) {
                cell.finishedImage.image = UIImage(named: "Ok-27.png")
            } else {
                cell.finishedImage.image = UIImage(named: "Circled_Dot-27.png")
            }
        }
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let cnt = savedCart.savedCartHeaderArray.count
        return cnt
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionHeader = savedCart.savedCartHeaderArray[section]
        let numberOfRows = savedCart.savedCartDictionary[sectionHeader]?.count
        return numberOfRows!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return savedCart.savedCartHeaderArray[section]
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let sectionHeader = savedCart.savedCartHeaderArray[indexPath.section]
            var itemInThis = savedCart.savedCartDictionary[sectionHeader]
            BackgroundFunctions.deleteRow(itemInThis![indexPath.row])
            (savedCart.savedCartDictionary[sectionHeader])?.removeAtIndex(indexPath.row)
            //savedCart.savedCartHeaderArray.removeAtIndex(indexPath.section)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // Actions
    @IBAction func refreshSavedCart(sender: UIBarButtonItem) {
        savedCart.getSavedCart()
        tableView.reloadData()
    }
    
    @IBAction func goBackHome() {
        self.performSegueWithIdentifier("unwindToHome", sender: self)
    }
}

extension SavedOrderMasterViewController: SavedOrderDetailViewControllerDelegate {
    func setFinishedOrder(cart: CatalogueCart) {
        (savedCart.savedCartDictionary[cart.user])![0].finished = cart.finished
    }
}