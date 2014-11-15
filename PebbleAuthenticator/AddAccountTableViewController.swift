//
//  AddAccountTableViewController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/15/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation
import UIKit

class AddAccountTableViewController: UITableViewController {
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        // Save the account
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
    }
}