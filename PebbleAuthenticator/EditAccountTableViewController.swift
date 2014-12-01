//
//  EditAccountTableViewController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/24/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation
import UIKit

class EditAccountTableViewController: UITableViewController, WatchSenderDelegate {
    let accountUniqueIDIndex = 0
    let accountNameIndex = 1
    let accountKeyIndex = 2
    let unixTimeStampIndex = 9

    var accountToEdit: Account!
    var delegate: AccountDetailViewController!
    
    func watchSendSuccessful() {
        let name = nameTextField.text
        let key = keyTextField.text
        // Save to core data
        accountToEdit.setAndSaveName(name)
        accountToEdit.setAndSaveTimeBasedKey(key)
        self.delegate.updateAccountTextFieldsWithName(name, andKey: key)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func watchSendFailure() {
        // Dont save to core data
        // Show a status alert
        var alert = UIAlertController(
            title: "Error",
            message: "Unable to edit account on watch.",
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        let name = nameTextField.text
        let key = keyTextField.text
        // Send to pebble
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let accountURL = accountToEdit.objectID.URIRepresentation()
        let accountID = accountURL.lastPathComponent
        
        appDelegate.sendDataToWatch(name, accountKey: key, lastDelegate: self)
    }
    
    override func viewDidLoad() {
        self.nameTextField.text = accountToEdit.name
        self.keyTextField.text = accountToEdit.timeBasedKey
        
        super.viewDidLoad()
    }
}