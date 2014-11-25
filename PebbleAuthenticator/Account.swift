//
//  Account.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/15/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Account)
class Account: NSManagedObject {
    @NSManaged var name : NSString
    @NSManaged var timeBasedKey : NSString
    
    func setAndSaveName(newName: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedContext = appDelegate.managedObjectContext {
            self.name = newName
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not edit account: \(error)")
            }
        }
    }
    
    func setAndSaveTimeBasedKey(newKey: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedContext = appDelegate.managedObjectContext {
            self.timeBasedKey = newKey
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not edit account: \(error)")
            }
        }
    }
    
    class func createNewAccount(newName: String, newTimeBasedKey: String) -> NSManagedObject? {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var resultAccount: NSManagedObject?
        if let managedContext = appDelegate.managedObjectContext {
            if let entity = NSEntityDescription.entityForName("Account",
                inManagedObjectContext: managedContext) {
                    let newAccount = NSManagedObject(entity: entity,
                        insertIntoManagedObjectContext: managedContext)
                    
                    newAccount.setValue(newName, forKey: "name")
                    newAccount.setValue(newTimeBasedKey, forKey: "timeBasedKey")
                    
                    var error: NSError?
                    if !managedContext.save(&error) {
                        println("Could not create new account: \(error)")
                    } else {
                        resultAccount = newAccount
                    }
            } else {
                println("Could not create new account: No entity description.")
            }
        } else {
            println("Could not create new account: No managed context.")
        }
        
        return resultAccount
    }
    
    class func fetchAllAccounts() -> [Account] {
        var resultAccounts = Array<Account>()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Account")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as  [Account]?
        
        if let results = fetchedResults {
            resultAccounts = results
        } else {
            println("Could not fetch Accounts: \(error)")
        }
        
        return resultAccounts
    }
}