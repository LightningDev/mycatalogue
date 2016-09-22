//
//  CatalogueScreens.swift
//  Catalog
//
//  Created by Nhat Tran on 9/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift
import ActionSheetPicker_3_0

enum PageOption: String {
    case MATERIAL_GROUP = "MaterialGroup"
    case SUB_MATERIAL_GROUP = "SubMaterialGroup"
    case ALL = "all"
}

class CatalogueScreens: UIViewController {
    
    // Check internet
    //    var checkConnection: Bool {
    //        return BackgroundFunctions.isConnectedToNetwork()
    //    }
    var checkConnection: Bool = false
    @IBOutlet weak var choiceMat: UISegmentedControl!
    var selectedOption: PageOption {
        if (self.choiceMat.selectedSegmentIndex == 1) {
            return .MATERIAL_GROUP
        } else if (self.choiceMat.selectedSegmentIndex == 2) {
            return .SUB_MATERIAL_GROUP
        } else {
            return .ALL
        }
    }
    
    // Pickerview
    @IBOutlet weak var matgroupView: UIView!
    @IBOutlet weak var matgroupPickerView: UIPickerView!
    @IBOutlet weak var matgroupBarButton :UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var numMatgroup: Int = 0
    var matgroupPickerData = [String]()
    var selectedItem: String?
    var selectedRow = 0
    
    // CollectionView
    @IBOutlet var myCollection: UICollectionView!
    var numCell: Int = 0
    let reuseIdentifier = "cell"
    var codeList = [String]()
    var descList = [String]()
    var stockList = [String]()
    var imageList = [NSURL]()
    var selectedCell: NSIndexPath!
    var catalogue: Catalogue = Catalogue()
    var numPages: Int {
        return numCell/3
    }
    
    var isSegue: Bool = true
    
    var filteredData: [Materials]!
    
    // Search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (selectedOption == .ALL) {
            loadAllOfflineMat()
        }
        searchBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueMatdetails") {
            //print("change page")
            let svc = segue.destinationViewController as! UINavigationController
            let controller = svc.topViewController as! CatalogueDetails
            controller.delegate = self
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject!) -> Bool {
        if identifier == "segueMatdetails" {
            return isSegue
        }
        return true
    }
    
    @IBAction func increaseStock(sender: UIButton) {
        
    }
    
    @IBAction func choiceMatIndexChanged(sender: UISegmentedControl) {
        switch self.selectedOption
        {
        case .MATERIAL_GROUP:
            matgroupBarButton.enabled = true
            loadAllGroup()
        case .SUB_MATERIAL_GROUP:
            matgroupBarButton.enabled = true
            loadAllSubGroup()
        case .ALL:
            matgroupBarButton.enabled = false
            loadAllOfflineMat()
        }
    }
    
    @IBAction func goToCart(sender: UIButton) {
        
    }
    
    // Load all offline material
    func loadAllOfflineMat() {
        catalogue.getAllFromRealm()
        filteredData = catalogue.materials
        numCell = filteredData.count
        myCollection.reloadData()
    }
    
    // Load all offline group
    func loadAllGroup() {
        numCell = 0
        myCollection.reloadData()
    }
    
    // Load all sub group
    func loadAllSubGroup() {
        numCell = 0
        myCollection.reloadData()
    }
    
    // Load material groups
    func chooseMatGroup(sender: UIBarButtonItem) {
        if (checkConnection) {
            // Send API request to get data
            let apiRequest = dispatch_group_create()
            self.catalogue.importMaterial(apiRequest)
            dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                let names = self.catalogue.toGroupNameArray()
                self.pickerViewShow(names, sender: sender)
            }
        } else {
            // Query from Realm
            BackgroundFunctions.mitigrateRealm()
            catalogue.getFromRealm()
            let names = catalogue.toGroupNameArray()
            pickerViewShow(names, sender: sender)
        }
    }
    
    func chooseSubMatGroup(sender: UIBarButtonItem) {
        if (checkConnection) {
            // Send API request to get data
            let apiRequest = dispatch_group_create()
            self.catalogue.importSubMaterialGroup(apiRequest)
            dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                let names = self.catalogue.toSubGroupNameArray()
                self.pickerViewShow(names, sender: sender)
            }
        } else {
            // Query from Realm
            BackgroundFunctions.mitigrateRealm()
            catalogue.getFromRealm()
            let names = catalogue.toSubGroupNameArray()
            pickerViewShow(names, sender: sender)
        }
    }
    
    func pickerViewShow(string: [String], sender: AnyObject?) {
        //print(string)
        ActionSheetMultipleStringPicker.showPickerWithTitle("Pick a group", rows: [
            string
            ], initialSelection: [1], doneBlock: {
                picker, values, indexes in
                let number = values[0]
                self.selectMatgroupButton(Int(number as! NSNumber))
                self.selectedRow = Int(number as! NSNumber)
                return
            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender )
    }
    
    @IBAction func addPopover(sender: UIBarButtonItem) {
        if (self.selectedOption == .MATERIAL_GROUP) {
            chooseMatGroup(sender)
        } else {
            chooseSubMatGroup(sender)
        }
    }
    
    // Select mat group from picker view
    func selectMatgroupButton(index: Int) {
        //self.selectedItem = self.matgroupPickerData[selectedRow]
        if ((index) >= 0 ) {
            let mgCode = self.catalogue.materialGroups[index].code
            if (self.numCell > 0) {
                self.numCell = 0
                self.myCollection.reloadData()
            }
            if (checkConnection) {
                let apiRequest = dispatch_group_create()
                self.catalogue.importSubMaterial(mgCode, index: index, apiRequest: apiRequest)
                dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                    //self.catalogue.downloadImage()
                    self.numCell = self.catalogue.materialGroups[index].materials.count
                    self.myCollection.reloadData()
                }
            } else {
                // Query from Realm
                self.numCell = self.catalogue.materialGroups[index].materials.count
                self.myCollection.reloadData()
            }
        }
    }
    
    @IBAction func goBackHome(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("unwindToHome", sender: self)
    }
    
    @IBAction func unwindToCatalogue(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func offline(sender: UIButton) {
        self.checkConnection = !self.checkConnection
    }
    
    // dismiss picker view
    @IBAction func cancelMatgroupButton(sender: UIButton) {
        hidePickerView(true)
    }
    
    // set visible on pickerview related components
    func hidePickerView(value: Bool) {
        self.matgroupView.hidden = value
        self.matgroupPickerView.hidden = value
        self.doneButton.hidden = value
        self.cancelButton.hidden = value
    }
    
    // Get material groups from server
    @available(*, deprecated=1.0) func loadMaterialGroups() {
        let url: String = NetworkList.Address.rawValue + NetworkList.MatgroupAddress.rawValue
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        if (!self.matgroupPickerData.isEmpty) {
            self.matgroupPickerData.removeAll()
            self.numMatgroup = 0
            self.matgroupPickerView.reloadAllComponents()
        }
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                
                let jsonArr  = dict["_embedded"]!["item"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                for i in 0..<jsonCnt {
                    let item = jsonArr[i]
                    let pickerItem: String = String(item["code"]!!) + "-" + String(item["description"]!!)
                    self.matgroupPickerData.append(pickerItem)
                }
                self.numMatgroup = jsonCnt
                self.hidePickerView(false)
                self.matgroupPickerView.reloadAllComponents()
            }else {
                print(error)
                return
            }
            
        }
    }
    
    // Get sub-material by material group
    @available(*, deprecated=1.0) func loadCatalogueList(mgCode: String) {
        let url: String = NetworkList.Address.rawValue + NetworkList.MatgroupAddress.rawValue + "/" + mgCode
        let username = NetworkList.Username.rawValue
        let password = NetworkList.Password.rawValue
        let networkHandler = NetworkHandler(endPointUrl: url, username: username, password: password)
        if (self.numCell > 0) {
            self.codeList.removeAll()
            self.descList.removeAll()
            self.stockList.removeAll()
            self.numCell = 0
            self.myCollection.reloadData()
        }
        networkHandler.sendGetRequest("", parameters: "") { response, error in
            if response != nil {
                let dict: NSDictionary = networkHandler.convertToDict(response!)
                let jsonArr  = dict["_embedded"]!["materials"] as! NSArray
                let jsonCnt: Int = jsonArr.count
                var indexArr: [NSIndexPath] = [NSIndexPath]()
                for i in 0..<jsonCnt {
                    let itemAt: Int = self.numCell + i
                    let index: NSIndexPath = NSIndexPath(forItem: itemAt, inSection: 0)
                    indexArr.append(index)
                    let item = jsonArr[i]
                    self.codeList.append(String(item["material_code"]!!))
                    self.descList.append(String(item["description"]!!))
                    self.stockList.append(String(item["stock"]!!))
                    var stringURl: String = String(item["path"]!!)
                    if (stringURl == "<null>") {
                        stringURl = ""
                    }
                    let url: NSURL = NSURL(string: stringURl)!
                    self.imageList.append(url)
                }
                self.numCell += jsonCnt
                self.myCollection.insertItemsAtIndexPaths(indexArr)
            }else {
                print(error)
                return
            }
        }
    }
}

// MARK: - Delegate protocol for detail page
extension CatalogueScreens: CatalogueDetailsDelegate {
    func loadCatalogueDetails(controller: CatalogueDetails) {
        let cell = self.myCollection.cellForItemAtIndexPath(self.selectedCell) as! GridViewCell
        var price = 0.0
        if (selectedOption != .ALL) {
            price = self.catalogue.materialGroups[selectedRow].materials[self.selectedCell.row].cash_p_m
        } else {
            price = catalogue.materials[selectedCell.row].cash_p_m
        }
        let qty = cell.stockField.text
        controller.codeLabel.text = cell.codeLabel.text
        controller.descriptionTextView.text = cell.descLabel.text
        controller.stockLabel.text = cell.stockQty.text
        controller.qtyTextfield.text = qty
        controller.imageView.image = cell.myImage.image
        controller.priceLabel.text = String(price)
        controller.totalPriceLabel.text = String(price * Double(qty!)!)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout protocol
extension CatalogueScreens: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        
        return CGSize(width: width / 3, height: height / 2)
    }
} 

// MARK: - UICollectionViewDataSource protocol
extension CatalogueScreens: UICollectionViewDataSource {
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.numCell)
        return self.numCell
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GridViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        
        if (self.numCell > 0 ) {
            if (self.selectedOption == .SUB_MATERIAL_GROUP) {
                
            } else if (self.selectedOption == .MATERIAL_GROUP) {
                
                cell.codeLabel.text = self.catalogue.materialGroups[selectedRow].materials[indexPath.row].code
                cell.descLabel.text = self.catalogue.materialGroups[selectedRow].materials[indexPath.row].desc
                cell.stockQty.text = "\(self.catalogue.materialGroups[selectedRow].materials[indexPath.row].stock) in stock"
                cell.stockField.tag = indexPath.row + 1
                cell.plusButton.tag = indexPath.row + 1
                cell.minusButton.tag = indexPath.row + 1
                let lightPurple = UIColor(red: 202.0/255.0, green: 156.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                cell.layer.borderColor = lightPurple.CGColor
                cell.layer.borderWidth = 1
                
            } else {
                cell.codeLabel.text = self.catalogue.materials[indexPath.row].code
                cell.descLabel.text = self.catalogue.materials[indexPath.row].desc
                cell.stockQty.text = "\(self.catalogue.materials[indexPath.row].stock) in stock"
                cell.stockField.tag = indexPath.row + 1
                cell.plusButton.tag = indexPath.row + 1
                cell.minusButton.tag = indexPath.row + 1
                let lightPurple = UIColor(red: 202.0/255.0, green: 156.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                cell.layer.borderColor = lightPurple.CGColor
                cell.layer.borderWidth = 1
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate protocol
extension CatalogueScreens: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        //print("You selected cell #\(indexPath.item)!")
        
        // get current cell
        self.selectedCell = indexPath
        
        // Write a shitty code just to catch the deadline - revamp later
        let alert = UIAlertController(title: "Options", message: "Please choose one", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Add to cart", style: .Default, handler: { (action: UIAlertAction!) in
            let order = Parts()
            var material = Materials()
            let cell = self.myCollection.cellForItemAtIndexPath(indexPath) as! GridViewCell
            var price = 0.0
            if (self.selectedOption != .ALL) {
                price = self.catalogue.materialGroups[self.selectedRow].materials[self.selectedCell.row].cash_p_m
            } else {
                price = self.catalogue.materials[self.selectedCell.row].cash_p_m
            }
            let qty = cell.stockField.text
            let totalPrice = price * Double(qty!)!
            if (self.selectedOption == .MATERIAL_GROUP) {
                material = self.catalogue.materialGroups[self.selectedRow].materials[indexPath.row]
            } else if (self.selectedOption == .SUB_MATERIAL_GROUP){
                
            } else {
                material = self.catalogue.materials[indexPath.row]
            }
            order.code = material.code
            order.desc = material.desc!
            order.total_qty = qty!
            order.total_amount_one = String(material.cash_p_m)
            order.sum_one = String(totalPrice)
            order.ma = ""
            
            // Read from realm
            BackgroundFunctions.mitigrateRealm()
            let realm = try! Realm()
            var user = BackgroundFunctions.getdefaultClient().code
            if (BackgroundFunctions.switchOff) {
                user = BackgroundFunctions.continueCustomer
            }
            let query = "user = '\(user)'"
            let results: Results<CatalogueCart> = realm.objects(CatalogueCart.self).filter(query)
            let catalogueCart = CatalogueCart()
            var catalogueCarts = [CatalogueCart]()
            catalogueCarts = Array(results)
            
            let cnt = catalogueCarts.count
            
            // Update stock of material
            try! realm.write {
                let result = realm.objects(Materials.self).filter("code = '\(material.code)'").first
                result!.stock -= Double(qty!)!
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
                            catalogueCarts[0].cart_total_price = catalogueCarts[0].cart_total_price + totalPrice
                        }
                    }
                } catch let error as NSError {
                    print(error)
                }
            } else {
                catalogueCart.code = "\(user)_\(cnt+1)"
                catalogueCart.cart_total_price = totalPrice
                catalogueCart.finished = false
                catalogueCart.user = user
                catalogueCart.created_date = NSDate()
                
                do {
                    try! realm.write {
                        realm.add(catalogueCart)
                        realm.add(order, update: true)
                        catalogueCart.items.append(order)
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Go to details", style: .Default, handler: { (action: UIAlertAction!) in
            self.isSegue = true
            let mapViewControllerObj = self.storyboard?.instantiateViewControllerWithIdentifier("CatalogueOrderDetailScene") as! CatalogueDetails
            //let catalogueDetail = mapViewControllerObj?.topViewController as! CatalogueDetails
            mapViewControllerObj.delegate = self
            self.navigationController!.pushViewController(mapViewControllerObj, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension CatalogueScreens: UISearchBarDelegate {
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = self.catalogue.materials
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = self.catalogue.forTheFuckSakeFilter(searchText)
            numCell = filteredData.count
            print(filteredData.first?.code)
        }
        myCollection.reloadData()
    }
    
}