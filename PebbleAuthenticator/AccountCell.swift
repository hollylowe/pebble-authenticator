//
//  AccountCell.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/25/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation
import UIKit

class AccountCell: UITableViewCell {
    
    @IBOutlet weak var accountKeyLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    
    func setName(name: String, andKey key: String) {
        self.accountNameLabel.text = name
        self.accountKeyLabel.text = key
        self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
}