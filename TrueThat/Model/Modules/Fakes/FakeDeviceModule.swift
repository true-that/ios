//
//  FakeDeviceModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class FakeDeviceModule: DeviceModule {
  var fakeDeviceId: String?
  override var deviceId: String? {
    return fakeDeviceId
  }

  init(_ deviceId: String) {
    super.init()
    self.fakeDeviceId = deviceId
  }
}
