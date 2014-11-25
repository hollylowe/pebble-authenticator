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
        let name = nameTextfield.text
        let key = keyTextfield.text
        
        if let newAccount = Account.createNewAccount(name, newTimeBasedKey: key) {
            // Send to pebble
            
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
           
            let accountURL = newAccount.objectID.URIRepresentation()
            let accountID = accountURL.lastPathComponent
            
            appDelegate.sendDataToWatch(accountID, accountName: name, accountKey: key, shouldDelete: false)
        }
        
        self.delegate.reloadTableView()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}