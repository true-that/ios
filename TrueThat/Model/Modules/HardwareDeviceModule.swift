//
//  HardwareDeviceModule.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class HardwareDeviceModule: DeviceModule {
  override var deviceId: String? {
    return UIDevice.current.identifierForVendor?.uuidString
  }
}
