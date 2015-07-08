//
//  RootWatchController.swift
//  DBus
//
//  Created by Paolo Coronati on 02/07/2015.
//  Copyright (c) 2015 Paolo Coronati. All rights reserved.
//

import WatchKit
import ModelManager

class RootWatchController: WKInterfaceController{
    override func willActivate() {
        super.willActivate()
        DBStopsManager.sharedInstance()
    }
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        if segueIdentifier == "favNearby"{
            return ["favorites": "yes"]
        }
        return nil
    }
}