//
//  MainTabBar.swift
//  Catalog
//
//  Created by Nhat Tran on 15/09/2016.
//  Copyright © 2016 iTMS. All rights reserved.
//

import UIKit

class MainTabBar: UITabBarController {
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (self.selectedIndex != 1)  {
            BackgroundFunctions.switchOff = false
        }
    }
}
