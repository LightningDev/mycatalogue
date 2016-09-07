//
//  NetworkManagerDelegate.swift
//  Catalog
//
//  Created by Nhat Tran on 5/09/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import Foundation

protocol NetworkManagerDelegate {
    func setProgressViewController(downloadPercentage: Float)
}

protocol SalesOrderImportAPIDelegate {
    func setSalesOrderProgress(importPercentage: Float)
}

protocol ContactsImportAPIDelegate {
    func contactsProgress(importPercentage: Float)
}