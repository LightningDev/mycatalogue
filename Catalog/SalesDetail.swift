//
//  SalesDetail.swift
//  Catalog
//
//  Created by Nhat Tran on 4/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import UIKit

class SalesDetail: UIViewController, UITableViewDataSource, UITableViewDelegate, SalesScreenDelegate, PartDetailsDelegate {
    
    @IBOutlet weak var collection: UITableView!
    var salesScreen: SalesScreen? = nil
    var salesDetails = SalesDetails()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let split = self.splitViewController {
            let navController = split.viewControllers.first as! UINavigationController
            self.salesScreen = navController.topViewController as? SalesScreen
        }
        
        self.salesScreen?.delegate = self
        collection.delegate = self
        collection.dataSource = self
        
        self.collection.tableFooterView = UIView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "seguePartDetails") {
            let svc = segue.destinationViewController as! PartDetails
            svc.delegate = self
        }
    }
    
    func getPartDetails(controller: PartDetails) {
        let selectedRow = self.collection.indexPathForSelectedRow?.row
        controller.codeLabel.text = self.salesDetails.salesDetail[selectedRow!].code
        controller.descLabel.text = self.salesDetails.salesDetail[selectedRow!].desc
        controller.parttypeLabel.text = self.salesDetails.salesDetail[selectedRow!].aloc_type
        controller.duedateField.text = self.salesDetails.salesDetail[selectedRow!].due_date_1
        controller.despField.text = self.salesDetails.salesDetail[selectedRow!].to_do
        controller.discField.text = self.salesDetails.salesDetail[selectedRow!].ma
        controller.unitpriceField.text = self.salesDetails.salesDetail[selectedRow!].total_amount_one
        controller.quantityField.text = self.salesDetails.salesDetail[selectedRow!].total_qty
        controller.taxField.text = self.salesDetails.salesDetail[selectedRow!].tax_pro
        controller.totalField.text = self.salesDetails.salesDetail[selectedRow!].sum_one
    }
    
    func setSalesDetail(sales: String) {
        let group = dispatch_group_create()
        self.salesDetails.importSales(sales, apiRequest: group)
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            self.collection.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cnt = self.salesDetails.salesDetail.count
        return cnt
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SalesDetailCells", forIndexPath: indexPath) as! SalesDetailCell
        cell.descLabel.text = self.salesDetails.salesDetail[indexPath.row].desc
        cell.codeLabel.text = self.salesDetails.salesDetail[indexPath.row].code
        return cell
    }
}


