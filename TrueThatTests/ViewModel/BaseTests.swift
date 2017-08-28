//
//  BaseTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
import SwiftyBeaver
@testable import TrueThat

class BaseTests: XCTestCase {
  public static let baseDir = URL(fileURLWithPath: "/Users/ohad/AppcodeProjects/TrueThat", isDirectory: true)
  public var fakeDetectionModule: FakeReactionDetectionModule!
  public var fakeDeviceModule: DeviceModule!
  public var fakeKeychainModule: FakeKeychainModule!
  override func setUp() {
    super.setUp()
    App.log.info("BaseTests started")
    fakeDetectionModule = FakeReactionDetectionModule()
    fakeDeviceModule = DeviceModule(deviceId: "iphone-mock")
    fakeKeychainModule = FakeKeychainModule()
    
    App.keychainModule = fakeKeychainModule
    App.authModule.current = User(id: 1, firstName: "Donald", lastName: "Trump",
                                  deviceId: fakeDeviceModule.deviceId)
    App.detecionModule = fakeDetectionModule
    App.deviceModule = fakeDeviceModule
  }
}
