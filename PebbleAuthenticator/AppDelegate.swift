//
//  AppDelegate.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/15/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PBPebbleCentralDelegate {

    var window: UIWindow?
    var targetWatch: PBWatch?
    var lastWatchSenderDelegate: WatchSenderDelegate?
    
    // Dictionarys sent to watch
    let accountNameIndex = 0
    let accountKeyIndex = 1
    
    var accounts = Array<Account>()
    var updateQueue = Array<NSDictionary>()
    
    func onSent(watch: PBWatch!, dictionary: [NSObject : AnyObject]!, error: NSError!) {
        if error == nil {
            if updateQueue.count == 1 {
                // the one at 0 was just sent and is the last one, so remove it
                updateQueue.removeAtIndex(0)
            } else if updateQueue.count > 1 {
                // the one at 0 was just sent, so remove it
                updateQueue.removeAtIndex(0)
                
                // but there are additional updates, so send them off
                let nextUpdateDictionary = updateQueue[0]
                watch.appMessagesPushUpdate(nextUpdateDictionary, onSent: onSent)
            }
        } else {
            updateQueue.removeAll(keepCapacity: false)
            
            println("Error: \(error)")
        }
        /*
        if error == nil {
            println("Update sent!")
            if let delegate = lastWatchSenderDelegate {
                delegate.watchSendSuccessful()
                lastWatchSenderDelegate = nil
            }
        } else {
            if let delegate = lastWatchSenderDelegate {
                delegate.watchSendFailure()
                lastWatchSenderDelegate = nil
            }
            println("Error: \(error)")
        }
        */
    }
    
    func updateWatchData() {
        if let watch = targetWatch {
            accounts = Account.fetchAllAccounts()
            
            let clearDictionary = [
                accountNameIndex: "",
                accountKeyIndex: ""
            ]
            
            updateQueue.append(clearDictionary)
            
            for account in accounts {
                let accountDictionary = [
                    accountNameIndex: account.name,
                    accountKeyIndex: account.timeBasedKey.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    ] as NSDictionary
                
                updateQueue.append(accountDictionary)
            }
            
            let firstUpdate = updateQueue[0]
            watch.appMessagesPushUpdate(firstUpdate, onSent: onSent)
        }
    }
    
    func sendDictionaryToWatch(dictionary: NSDictionary, lastWatchDelegate: WatchSenderDelegate) {
        lastWatchSenderDelegate = lastWatchDelegate
        if let watch = targetWatch {
            if watch.connected == false {
                var alert = UIAlertController(
                    title: "Error",
                    message: "Watch is not connected",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                if let window = self.window {
                    if let root = window.rootViewController as? UINavigationController {
                        root.visibleViewController.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            } else {
                watch.appMessagesPushUpdate(dictionary, onSent: onSent)
            }
            
        }
    }
    
    func clearWatchData() {
        if let watch = targetWatch {
            if watch.connected == false {
                var alert = UIAlertController(
                    title: "Error",
                    message: "Watch is not connected",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                if let window = self.window {
                    if let root = window.rootViewController as? UINavigationController {
                        root.visibleViewController.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            } else {
                let update = [
                    accountNameIndex: "",
                    accountKeyIndex: ""
                ]
                
                let updateDict = update as NSDictionary
                println("Clearing watch data...")
                watch.appMessagesPushUpdate(updateDict, onSent: onSent)
            }
            
        }

    }
    
    func sendDataToWatch(accountName: String, accountKey: String, lastDelegate: WatchSenderDelegate) {
        lastWatchSenderDelegate = lastDelegate
        if let watch = targetWatch {
            if watch.connected == false {
                var alert = UIAlertController(
                    title: "Error",
                    message: "Watch is not connected",
                    preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                if let window = self.window {
                    if let root = window.rootViewController as? UINavigationController {
                        root.visibleViewController.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            } else {
                let unixTimeStamp = NSDate().timeIntervalSince1970

                let update = [
                    accountNameIndex: accountName,
                    accountKeyIndex: accountKey
                ]
                
                let updateDict = update as NSDictionary
                
                println("Sending dictionary:")
                println(" \(updateDict)")
                
                watch.appMessagesPushUpdate(updateDict, onSent: onSent)
                
            }
            
        }
    }
    
    func setTargetWatch(watch: PBWatch) {
        self.targetWatch = watch
        
        // For Pebras (testing stuff out):
        var bytes: [UInt8] = [0x79, 0x68, 0xb8, 0x07, 0x8d, 0x6d, 0x4a, 0xb9, 0xa8, 0x79, 0xc5, 0xa8, 0x21, 0x6e, 0x8a, 0x64]
        // For Authenticator:
        // var bytes: [UInt8] = [0x94, 0x8c, 0x07, 0x11, 0x3c, 0xe6, 0x4d, 0x6b, 0xb1, 0xc9, 0x60, 0xc1, 0xea, 0xf7, 0x81, 0xb3]
        var uuid: NSData = NSData(bytes: bytes, length: bytes.count * sizeof(UInt8))
        
        PBPebbleCentral.defaultCentral().appUUID = uuid;
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
        PBPebbleCentral.defaultCentral().delegate = self;
        
        // Initialize with the last connected watch:
        self.setTargetWatch(PBPebbleCentral.defaultCentral().lastConnectedWatch())
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "CryptoKnights.PebbleAuthenticator" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("PebbleAuthenticator", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("PebbleAuthenticator.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

extension AppDelegate: PBPebbleCentralDelegate {
    func pebbleCentral(central: PBPebbleCentral!, watchDidConnect watch: PBWatch!, isNew: Bool) {
        
    }
    
    func pebbleCentral(central: PBPebbleCentral!, watchDidDisconnect watch: PBWatch!) {
        
    }
}

