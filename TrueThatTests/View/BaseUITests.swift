//
//  BaseUITests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
import SwiftyBeaver
@testable import TrueThat

class BaseUITests : KIFTestCase {
  public var fakeDetectionModule: FakeReactionDetectionModule!
  public var fakeDeviceModule: DeviceModule!
  public var fakeKeychainModule: FakeKeychainModule!
  override func setUp() {
    super.setUp()
    App.log.info("BaseUITests started")
    fakeDetectionModule = FakeReactionDetectionModule()
    fakeDeviceModule = FakeDeviceModule("fake-iPhone")
    fakeKeychainModule = FakeKeychainModule()
    
    App.keychainModule = fakeKeychainModule
    App.authModule.current = User(id: 1, firstName: "Donald", lastName: "Trump",
                                  deviceId: fakeDeviceModule.deviceId)
    App.detecionModule = fakeDetectionModule
    App.deviceModule = fakeDeviceModule
    KIFTestActor.setDefaultTimeout(1.0)
  }
}
