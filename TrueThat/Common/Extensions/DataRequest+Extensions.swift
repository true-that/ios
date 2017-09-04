//
//  DataRequest+Extensions.swift
//  TrueThat
//
//  Created by Ohad Navon on 19/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Alamofire
import Crashlytics

extension DataRequest {
  @discardableResult public func log() -> Self {
    App.log.info("\(self)")
    if request?.url?.absoluteURL != nil {
      Crashlytics.sharedInstance().setObjectValue(
        request!.url!.absoluteURL, forKey: LoggingKey.lastNetworkRequest.rawValue)
    }
    return self
  }
}
