//
//  BaseViewModelTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat

class BaseViewModelTests: XCTestCase {
  public var fakeDetectionModule: FakeReactionDetectionModule!
  override func setUp() {
    super.setUp()
    fakeDetectionModule = FakeReactionDetectionModule()
    App.detecionModule = fakeDetectionModule
  }
}
