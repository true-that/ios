//
//  BaseUITests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat

class BaseUITests : KIFTestCase {
  public var fakeDetectionModule: FakeReactionDetectionModule!
  public var fakeAuthModule: FakeAuthModule!
  public var fakeDeviceModule: DeviceModule!
  override func setUp() {
    super.setUp()
    fakeDetectionModule = FakeReactionDetectionModule()
    fakeAuthModule = FakeAuthModule()
    fakeDeviceModule = DeviceModule(deviceId: "iphone-mock")
    fakeAuthModule.current = User(id: 1, firstName: "Donald", lastName: "Trump",
                                  deviceId: fakeDeviceModule.deviceId)
    App.detecionModule = fakeDetectionModule
    App.authModule = fakeAuthModule
    App.deviceModule = fakeDeviceModule
    KIFTestActor.setDefaultTimeout(1.0)
  }
}