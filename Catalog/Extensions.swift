//
//  Extensions.swift
//  Catalog
//
//  Created by Nhat Tran on 12/07/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func downloadedFrom(url: NSURL, contentMode mode: UIViewContentMode = .ScaleAspectFit) {
        let networkHandler = NetworkHandler(endPointUrl: "", username: "", password: "")
        
        networkHandler.getDataFromUrl(url) { data, response, error in
            if data != nil {
                self.image = UIImage(data: data)
            } else {
                print(error)
            }
        }
        
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}