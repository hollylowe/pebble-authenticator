//
//  AccountDetailViewController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/24/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation

class AccountDetailViewController: UITableViewController {

    let accountDetailToEditAccountSegueIdentifier = "AccountDetailToEditAccountSegue"
    
    // Implicit, set by previous view
    var account: Account!
    var delegate: MainTableViewController!
    
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var keyCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        
        if let textLabel = self.nameCell.textLabel {
            textLabel.text = account.name
        }

        if let textLabel = self.keyCell.textLabel {
            textLabel.text = account.timeBasedKey
        }
        
        super.viewDidLoad()

    }
    
    @IBAction func editAccountButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier(accountDetailToEditAccountSegueIdentifier, sender: self)
    }
    
    func updateAccountTextFieldsWithName(name: String, andKey key: String) {
        if let textLabel = self.nameCell.textLabel {
            textLabel.text = name
        }
        
        if let textLabel = self.keyCell.textLabel {
            textLabel.text = key
        }

        self.title = name
        self.delegate.reloadTableView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == accountDetailToEditAccountSegueIdentifier {
            let navigationController = segue.destinationViewController as UINavigationController
            let viewControllers = navigationController.viewControllers
            let editAccountViewController = viewControllers[0] as EditAccountTableViewController
            editAccountViewController.delegate = self
            editAccountViewController.accountToEdit = account
        }
    }
    
    
}