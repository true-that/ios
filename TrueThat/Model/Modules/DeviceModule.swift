//
//  DeviceModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

/// Manages device data such as phone number and identifiers.
class DeviceModule {
  var deviceId: String?

  init(deviceId: String?) {
    self.deviceId = deviceId
  }
}
