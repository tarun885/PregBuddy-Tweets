//
//  TabBarVC.swift
//  PregBuddy Tweets
//
//  Created by Tarun Jain on 05/03/18.
//  Copyright © 2018 PregBuddy. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBar.appearance().tintColor = UIColor(red:0.15, green:0.74, blue:0.62, alpha:1.0)
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
        } else {
            // Fallback on earlier versions
        }
        UITabBar.appearance().barTintColor = UIColor.white
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().isOpaque = false
    }

}
