//
//  PartDetails.swift
//  Catalog
//
//  Created by Nhat Tran on 9/08/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

protocol PartDetailsDelegate {
    func getPartDetails(controller: PartDetails)
}

class PartDetails: UIViewController {
    @IBOutlet weak var totalField: UITextField!
    @IBOutlet weak var taxField: UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var unitpriceField: UITextField!
    @IBOutlet weak var discField: UITextField!
    @IBOutlet weak var despField: UITextField!
    @IBOutlet weak var duedateField: UITextField!
    @IBOutlet weak var parttypeLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    var delegate: PartDetailsDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.delegate != nil) {
            self.delegate?.getPartDetails(self)
        }
    }
}
