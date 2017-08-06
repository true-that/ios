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
  public var authModule: AuthModule!
  override func setUp() {
    super.setUp()
    fakeDetectionModule = FakeReactionDetectionModule()
    authModule = AuthModule()
    App.detecionModule = fakeDetectionModule
    App.authModule = authModule
    KIFTestActor.setDefaultTimeout(1.0)
  }
}
