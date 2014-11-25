//
//  EditAccountTableViewController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/24/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation
import UIKit

class EditAccountTableViewController: UITableViewController {
    let accountUniqueIDIndex = 0
    let accountNameIndex = 1
    let accountKeyIndex = 2
    let unixTimeStampIndex = 9

    var accountToEdit: Account!
    var delegate: AccountDetailViewController!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        let name = nameTextField.text
        let key = keyTextField.text
        
        accountToEdit.setAndSaveName(name)
        accountToEdit.setAndSaveTimeBasedKey(key)
        
        self.delegate.updateAccountTextFieldsWithName(nameTextField.text, andKey: keyTextField.text)
        
        // Send to pebble
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let accountURL = accountToEdit.objectID.URIRepresentation()
        let accountID = accountURL.lastPathComponent
        
        appDelegate.sendDataToWatch(accountID, accountName: name, accountKey: key, shouldDelete: false)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.nameTextField.text = accountToEdit.name
        self.keyTextField.text = accountToEdit.timeBasedKey
        
        super.viewDidLoad()
    }
}