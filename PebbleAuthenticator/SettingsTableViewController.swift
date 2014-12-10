//
//  SettingsTableViewController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/25/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var connectedWatchCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let textLabel = self.connectedWatchCell.textLabel {
            textLabel.text = "Connected Watch"
        }
        
        if let watch = appDelegate.targetWatch {
            if let detailTextLabel = self.connectedWatchCell.detailTextLabel {
              detailTextLabel.text = watch.name
            }
        } else {
            if let detailTextLabel = self.connectedWatchCell.detailTextLabel {
                detailTextLabel.text = "None"
            }
        }
    }
}