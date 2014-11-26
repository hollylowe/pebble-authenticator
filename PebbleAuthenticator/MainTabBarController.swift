//
//  MainTabBarController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/25/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBar
        if let items = tabBar.items {
            let accountsTabBarItem = items[0] as UITabBarItem
            let settingsTabBarItem = items[1] as UITabBarItem
            let imageSize = CGSizeMake(30, 30)

            if let accountsSelectedIcon = UIImage(named: "lock_full.png") {
                accountsTabBarItem.selectedImage = imageWithImage(accountsSelectedIcon, scaledToSize: imageSize)
            }
            
            if let accountsDefaultIcon = UIImage(named: "lock_line.png") {
                accountsTabBarItem.image = imageWithImage(accountsDefaultIcon, scaledToSize: imageSize)
            }
            
            if let settingsSelectedIcon = UIImage(named: "settings_full.png") {
                settingsTabBarItem.selectedImage = imageWithImage(settingsSelectedIcon, scaledToSize: imageSize)

            }
            
            if let settingsDefaultIcon = UIImage(named: "settings_line.png") {
                settingsTabBarItem.image = imageWithImage(settingsDefaultIcon, scaledToSize: imageSize)

            }
            
        }
    }
    
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}