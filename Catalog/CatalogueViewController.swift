//
//  CatalogueViewController.swift - New version
//  Catalog
//
//  Created by Nhat Tran on 15/09/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class CatalogueViewController: UIViewController {
    
    // CollectionView
    @IBOutlet weak var horizontalCollection: UICollectionView!
    var catalogue: Catalogue = Catalogue()
    
    // Searchbar
    @IBOutlet weak var searchBarController: UISearchBar!
    
    // SegmentedController
    @IBOutlet weak var groupOptions: UISegmentedControl!
    var selectedOption: PageOption {
        if (self.groupOptions.selectedSegmentIndex == 1) {
            return .MATERIAL_GROUP
        } else if (self.groupOptions.selectedSegmentIndex == 2) {
            return .SUB_MATERIAL_GROUP
        } else {
            return .ALL
        }
    }
    
    // Bar button
    @IBOutlet weak var selectSpecificGroup: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (selectedOption == .ALL) {
            loadAllMaterials()
        }
        
        searchBarController.delegate = self
    }
    
    // Load all offline material
    func loadAllMaterials() {
        catalogue.getAllFromRealm()
        
    }
    
    // Load all Sub groups 
    func loadAllSubgroup() {
        
    }
    
    // Load all Group() {
    func loadAllGroup() {
        
    }
    
    // Pick specific group
    func pickGroup() {
        
    }
}

// MARK: - UICollectionViewDataSource protocol
extension CatalogueViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CatalogueCollectionViewCells", forIndexPath: indexPath) as! GridViewCell
        
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout protocol
extension CatalogueViewController: UICollectionViewDelegateFlowLayout {
    
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

// MARK: - UICollectionViewDelegate protocol
extension CatalogueViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}

// MARK: - UISearchBarDelegate protocol
extension CatalogueViewController: UISearchBarDelegate {
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            
        } else {
            
        }
        
    }
    
}

