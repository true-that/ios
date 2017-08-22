//
//  BaseTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat

class BaseTests: XCTestCase {
  public var fakeDetectionModule: FakeReactionDetectionModule!
  public var fakeDeviceModule: DeviceModule!
  override func setUp() {
    super.setUp()
    fakeDetectionModule = FakeReactionDetectionModule()
    fakeDeviceModule = DeviceModule(deviceId: "iphone-mock")
    App.authModule.current = User(id: 1, firstName: "Donald", lastName: "Trump",
                                  deviceId: fakeDeviceModule.deviceId)
    App.detecionModule = fakeDetectionModule
    App.deviceModule = fakeDeviceModule
  }
}
