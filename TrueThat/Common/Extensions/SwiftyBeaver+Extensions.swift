//
//  SwiftyBeaver+Extensions.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import SwiftyBeaver
import Crashlytics

extension SwiftyBeaver {
  class func report(_ message: String, withError: NSError) {
    error(message)
    Crashlytics.sharedInstance().recordError(withError)
  }
}
