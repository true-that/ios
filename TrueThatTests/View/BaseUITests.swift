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
  override func setUp() {
    super.setUp()
    App.detecionModule = FakeReactionDetectionModule()
  }
}
