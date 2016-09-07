//
//  CatalogueScreens.swift
//  Catalog
//
//  Created by Nhat Tran on 9/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit
import RealmSwift

enum PageOption: String {
    case MATERIAL_GROUP = "MaterialGroup"
    case SUB_MATERIAL_GROUP = "SubMaterialGroup"
}

class CatalogueScreens: UIViewController {
    
    // Check internet
    //    var checkConnection: Bool {
    //        return BackgroundFunctions.isConnectedToNetwork()
    //    }
    var checkConnection: Bool = false
    @IBOutlet weak var choiceMat: UISegmentedControl!
    var selectedOption: PageOption {
        if (self.choiceMat.selectedSegmentIndex == 0) {
            return .MATERIAL_GROUP
        } else {
            return .SUB_MATERIAL_GROUP
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.matgroupPickerView.dataSource = self
        self.matgroupPickerView.delegate = self
        self.matgroupView.alpha = 0.5
        hidePickerView(true)
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
    
    @IBAction func increaseStock(sender: UIButton) {
        
    }
    
    @IBAction func choiceMatIndexChanged(sender: UISegmentedControl) {
//        switch self.selectedOption
//        {
//        case .MATERIAL_GROUP:
//            self.matgroupBarButton.title = "Material Group"
//        case .SUB_MATERIAL_GROUP:
//            self.matgroupBarButton.title = "Sub Material Group"
//        }
    }
    
    @IBAction func goToCart(sender: UIButton) {
        
    }
    
    // Load material groups
    func chooseMatGroup() {
        if (checkConnection) {
            // Send API request to get data
            let apiRequest = dispatch_group_create()
            self.catalogue.importMaterial(apiRequest)
            dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                self.hidePickerView(false)
                self.matgroupPickerView.reloadAllComponents()
            }
        } else {
            // Query from Realm
            BackgroundFunctions.mitigrateRealm()
            catalogue.getFromRealm()
            self.hidePickerView(false)
            self.matgroupPickerView.reloadAllComponents()
        }
    }
    
    func chooseSubMatGroup() {
        if (checkConnection) {
            // Send API request to get data
            let apiRequest = dispatch_group_create()
            self.catalogue.importSubMaterialGroup(apiRequest)
            dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                //print("done submatgrou[")
                self.hidePickerView(false)
                self.matgroupPickerView.reloadAllComponents()
            }
        } else {
            // Query from Realm
            BackgroundFunctions.mitigrateRealm()
            catalogue.getFromRealm()
            self.hidePickerView(false)
            self.matgroupPickerView.reloadAllComponents()
        }
    }
    
    @IBAction func addPopover(sender: UIBarButtonItem) {
        if (self.selectedOption == .MATERIAL_GROUP) {
            chooseMatGroup()
        } else {
            chooseSubMatGroup()
        }
    }
    
    // Select mat group from picker view
    @IBAction func selectMatgroupButton(sender: UIButton) {
        let selectedRow = self.matgroupPickerView.selectedRowInComponent(0)
        //self.selectedItem = self.matgroupPickerData[selectedRow]
        if ((selectedRow) >= 0 ) {
            let mgCode = self.catalogue.materialGroups[selectedRow].code
            hidePickerView(true)
            if (self.numCell > 0) {
                self.numCell = 0
                self.myCollection.reloadData()
            }
            if (checkConnection) {
                let apiRequest = dispatch_group_create()
                self.catalogue.importSubMaterial(mgCode, index: selectedRow, apiRequest: apiRequest)
                dispatch_group_notify(apiRequest, dispatch_get_main_queue()) {
                    //self.catalogue.downloadImage()
                    self.numCell = self.catalogue.materialGroups[selectedRow].materials.count
                    self.myCollection.reloadData()
                }
            } else {
                // Query from Realm
                self.numCell = self.catalogue.materialGroups[selectedRow].materials.count
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
        let selectedRow = self.matgroupPickerView.selectedRowInComponent(0)
        let price: Double = self.catalogue.materialGroups[selectedRow].materials[self.selectedCell.row].cash_p_m
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

// MARK: - UIPickerViewDataSource
extension CatalogueScreens: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //print("delegate numMatgroup=\(self.numMatgroup)")
        var cnt = self.catalogue.countGroup
        if (self.selectedOption == .SUB_MATERIAL_GROUP) {
            cnt = self.catalogue.countSubGroup
        }
        //print("\(self.selectedOption) \(cnt)")
        return cnt
    }
}

// MARK: - UIPickerViewDelegate
extension CatalogueScreens: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (self.selectedOption == .SUB_MATERIAL_GROUP) {
            return self.catalogue.subMaterialGroups[row].code
        } else {
            return self.catalogue.materialGroups[row].code
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (self.selectedOption == .SUB_MATERIAL_GROUP) {
            self.selectedItem = self.catalogue.subMaterialGroups[row].code
        } else {
            self.selectedItem = self.catalogue.materialGroups[row].code
        }
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
        return self.numCell
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GridViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        
        if (self.numCell > 0 ) {
            if (self.selectedOption == .SUB_MATERIAL_GROUP) {
                
            } else {

                let selectedRow = self.matgroupPickerView.selectedRowInComponent(0)
                
                cell.codeLabel.text = self.catalogue.materialGroups[selectedRow].materials[indexPath.row].code
                cell.descLabel.text = self.catalogue.materialGroups[selectedRow].materials[indexPath.row].desc
                cell.stockQty.text = "\(self.catalogue.materialGroups[selectedRow].materials[indexPath.row].stock) in stock"
                cell.stockField.tag = indexPath.row + 1
                cell.plusButton.tag = indexPath.row + 1
                cell.minusButton.tag = indexPath.row + 1
//                if (!self.checkConnection) {
//                    let imgPath = self.imageList[indexPath.row].path!
//                    cell.myImage.image = UIImage(contentsOfFile: imgPath)
//                } else {
//                    //cell.myImage.downloadedFrom(self.imageList[indexPath.row])
//                }
                
                // Test purpose
                //cell.myImage.image = UIImage(contentsOfFile: "RC39221.jpg")
                
                //            cell.backgroundColor = UIColor.whiteColor() // make cell more visible in our example project
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
    }
    
}


