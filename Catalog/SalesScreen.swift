//
//  SalesScreen.swift
//  Catalog
//
//  Created by Nhat Tran on 9/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

protocol SalesScreenDelegate {
    func setSalesDetail(salesCode: String)
}

class SalesScreen: UIViewController {
    
    // Properties
    let saleOrderList = SalesOrders()
    @IBOutlet weak var tableView: UITableView!
    var delegate: SalesScreenDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning(  ) {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Actions
    @IBAction func refreshSalesList() {
        let group = dispatch_group_create()
        self.saleOrderList.importSales(group)
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            self.saleOrderList.setupDictionary()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func goBackHome() {
        self.performSegueWithIdentifier("unwindToHome", sender: self)
    }
}

extension SalesScreen: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        let section = indexPath.section
        if (self.delegate != nil) {
            let itemSales = self.saleOrderList.alphaSalesOrders[self.saleOrderList.alphaIndex[section]]
            
            self.delegate?.setSalesDetail(itemSales![row].code)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SalesCells", forIndexPath: indexPath) as! SalesCell
        
        if (self.saleOrderList.salesOrders.count > 0) {
            let itemSales = self.saleOrderList.alphaSalesOrders[self.saleOrderList.alphaIndex[indexPath.section]]
            cell.nameLabel.text = itemSales![indexPath.row].code
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //print(self.saleOrderList.alphaIndex.count)
        return self.saleOrderList.alphaIndex.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cnt = (self.saleOrderList.alphaSalesOrders[self.saleOrderList.alphaIndex[section]]?.count)
        if (cnt == nil) {
            cnt = 0
        }
        return cnt!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.saleOrderList.alphaIndex[section]
    }
}
