//
//  CatalogueDetails.swift
//  Catalog
//
//  Created by Nhat Tran on 20/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

protocol CatalogueDetailsDelegate {
    func loadCatalogueDetails(controller: CatalogueDetails)
}

class CatalogueDetails: UIViewController {
    @IBOutlet weak var codeText: UITextField!
    @IBOutlet weak var descText: UITextField!
    @IBOutlet weak var stockText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var image: UIImageView!
    var delegate: CatalogueDetailsDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.delegate != nil) {
            self.delegate?.loadCatalogueDetails(self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
