//
//  HardwareDeviceModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class HardwareDeviceModule: DeviceModule {
  init() {
    super.init(deviceId: UIDevice.current.identifierForVendor!.uuidString)
  }
}
