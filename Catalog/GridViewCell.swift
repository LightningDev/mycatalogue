//
//  GridViewCell.swift
//  Catalog
//
//  Created by Nhat Tran on 13/06/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit


class GridViewCell: UICollectionViewCell {
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var stockField: UITextField!
    @IBOutlet weak var stockQty: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var addToCart: UIButton!
    
    @IBAction func addToCart(sender: UIButton) {
        
    }
    
    @IBAction func increaseQty(sender: UIButton) {
        let selectedTag = sender.tag
        let textField: UITextField = self.viewWithTag(selectedTag) as! UITextField
        let value: Int = Int(textField.text!)! + 1
        textField.text = String(value)
    }
    
    @IBAction func decreaseQty(sender: UIButton) {
        let selectedTag = sender.tag
        let textField: UITextField = self.viewWithTag(selectedTag) as! UITextField
        var value: Int = Int(textField.text!)!
        if (value > 0) {
            value -= 1
        }
        textField.text = String(value)
    }
}
