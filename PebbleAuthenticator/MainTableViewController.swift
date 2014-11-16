//
//  ViewController.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/15/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    var accounts = Array<Account>()
    let mainToAddAccountSegueIdentifier = "MainToAddAccountSegue"
    
    override func viewDidLoad() {
        accounts = Account.fetchAllAccounts()
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
        }
        
        super.prepareForSegue(segue, sender: sender)
    }

    func deleteAccountRowAction(rowAction: UITableViewRowAction!, indexPath: NSIndexPath!) {
        self.tableView.beginUpdates()
        
        let account = accounts[indexPath.row]
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let context = appDelegate.managedObjectContext {
           context.deleteObject(account)
        }
        appDelegate.saveContext()
        
        accounts = Account.fetchAllAccounts()
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        
        
        self.tableView.endUpdates()
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
        let cell = UITableViewCell()
        let account = accounts[indexPath.row]
        cell.textLabel.text = account.valueForKey("name") as String!
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
}
