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
    // Implicit - set by previous view controller
    var delegate: MainTableViewController!
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var keyTextfield: UITextField!
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        // Save the account
        Account.createNewAccount(nameTextfield.text, newTimeBasedKey: keyTextfield.text)
        // Send to pebble?
        
        // reload table view
        self.delegate.reloadTableView()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
    }
}