//
//  DataRequest+Extensions.swift
//  TrueThat
//
//  Created by Ohad Navon on 19/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Alamofire

extension DataRequest {
  @discardableResult public func log() -> Self {
    App.log.info("\(self)")
    return self
  }
}
