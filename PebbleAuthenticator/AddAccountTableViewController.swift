//
//  AddAccountTableViewController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/15/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddAccountTableViewController: UITableViewController, WatchSenderDelegate {
    // Implicit - set by previous view controller
    var delegate: MainTableViewController!
    var lastCreatedAccount: NSManagedObject?
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var keyTextfield: UITextField!
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func watchSendSuccessful() {
        /*
        lastCreatedAccount = nil
        self.delegate.reloadTableView()
        self.dismissViewControllerAnimated(true, completion: nil)
        */
    }
    
    func watchSendFailure() {
        /*
        if let account = lastCreatedAccount {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            // Delete from core data
            if let context = appDelegate.managedObjectContext {
                context.deleteObject(account)
            }
            appDelegate.saveContext()
            
            // Show a status alert
            var alert = UIAlertController(
                title: "Error",
                message: "Unable to add account to watch.",
                preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        */
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        let name = nameTextfield.text
        let key = keyTextfield.text
        
        // Create an account
        Account.createNewAccount(name, newTimeBasedKey: key)
        
        // Update watch
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.updateWatchData()
        self.delegate.reloadTableView()
        self.dismissViewControllerAnimated(true, completion: nil)
        /*
        Account.createNewAccount(name, newTimeBasedKey: key)

        self.delegate.reloadTableView()
        self.delegate.updateWatchData()
        self.dismissViewControllerAnimated(true, completion: nil)
        */
        
        /*
        if let newAccount = Account.createNewAccount(name, newTimeBasedKey: key) {
            // Send to Pebble
            lastCreatedAccount = newAccount
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let accountURL = newAccount.objectID.URIRepresentation()
            let accountID = accountURL.lastPathComponent
            
            appDelegate.sendDataToWatch(name,
                accountKey: key,
                lastDelegate: self
            )
        }
        */
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}