//
//  WatchSenderDelegate.swift
//  PebbleAuthenticator
//
//  Created by Lucas David on 11/25/14.
//  Copyright (c) 2014 CryptoKnights. All rights reserved.
//

import Foundation

protocol WatchSenderDelegate {
    func watchSendSuccessful()
    func watchSendFailure()
}