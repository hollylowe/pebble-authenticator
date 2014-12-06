//
//  ViewController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/15/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, WatchSenderDelegate {
    var accounts = Array<Account>()
    let mainToAddAccountSegueIdentifier = "MainToAddAccountSegue"
    let mainToAccountDetailSegueIdentifier = "MainToAccountDetailSegue"
    var lastDeleteIndexPath: NSIndexPath?
    
    var updatesToSend = Array<NSDictionary>()
    
    let accountNameIndex = 0
    let accountKeyIndex = 1
    
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.updateWatchData()
    }
    
    
    func watchSendFailure() {
        
        var alert = UIAlertController(
            title: "Error",
            message: "Unable to delete account from watch.",
            preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func watchSendSuccessful() {
        /*
        if updatesToSend.count > 0 {
            updatesToSend.removeAtIndex(0)
            if updatesToSend.count > 0 {
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                appDelegate.sendDictionaryToWatch(updatesToSend[0], lastWatchDelegate: self)
            }
        }
        */
        
        
        if let indexPath = lastDeleteIndexPath {
            deleteAccount(indexPath)
            lastDeleteIndexPath = nil
        }
        
    }

    override func viewDidLoad() {
        accounts = Account.fetchAllAccounts()
        self.tableView.tableFooterView = UIView()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadTableView() {
        accounts = Account.fetchAllAccounts()
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == mainToAddAccountSegueIdentifier {
            let navigationController = segue.destinationViewController as UINavigationController
            let viewControllers = navigationController.viewControllers
            let addAccountViewController = viewControllers[0] as AddAccountTableViewController
            addAccountViewController.delegate = self
        } else if segue.identifier == mainToAccountDetailSegueIdentifier {
            let accountDetailViewController = segue.destinationViewController as AccountDetailViewController
            accountDetailViewController.delegate = self
            accountDetailViewController.account = sender as Account
            accountDetailViewController.title = (sender as Account).name
        }
        
        super.prepareForSegue(segue, sender: sender)
    }

    func deleteAccount(indexPath: NSIndexPath) {
        let account = accounts[indexPath.row]
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        self.tableView.beginUpdates()

        // Delete from core data
        if let context = appDelegate.managedObjectContext {
            context.deleteObject(account)
        }
        
        appDelegate.saveContext()
        accounts = Account.fetchAllAccounts()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        
        self.tableView.endUpdates()
    }
    
    func deleteAccountRowAction(rowAction: UITableViewRowAction!, indexPath: NSIndexPath!) {
        deleteAccount(indexPath)
        
        /*
        lastDeleteIndexPath = indexPath
        let account = accounts[indexPath.row]
        */
        /*
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let accountURL = account.objectID.URIRepresentation()
        let accountID = accountURL.lastPathComponent
        appDelegate.sendDataToWatch(account.name, accountKey: account.timeBasedKey, lastDelegate: self)
        */
        
        // Send to watch
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.updateWatchData()
    }
    
}

extension MainTableViewController: UITableViewDelegate {
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: deleteAccountRowAction)
        deleteAction.backgroundColor = UIColor.redColor()
        
        return [deleteAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension MainTableViewController: UITableViewDataSource {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AccountCellIdentifier") as AccountCell
        
        let account = accounts[indexPath.row]
        let name = account.valueForKey("name") as String!
        let key = account.valueForKey("timeBasedKey") as String!
        
        cell.setName(name, andKey: key)
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let account = accounts[indexPath.row]
        
        self.performSegueWithIdentifier(mainToAccountDetailSegueIdentifier, sender: account)
    }
}
