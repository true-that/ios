//
//  NumberHelperTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import Nimble

class NumberHelperTests: XCTestCase {
  func testTruncation() {
    expect(NumberHelper.truncate(5)).to(equal("5"))
    expect(NumberHelper.truncate(-0)).to(equal("0"))
    expect(NumberHelper.truncate(-5)).to(equal("-5"))
    expect(NumberHelper.truncate(999)).to(equal("999"))
    expect(NumberHelper.truncate(-1200)).to(equal("-1.2k"))
    expect(NumberHelper.truncate(60400)).to(equal("60k"))
    expect(NumberHelper.truncate(999000)).to(equal("999k"))
    expect(NumberHelper.truncate(1000000)).to(equal("1m"))
    expect(NumberHelper.truncate(9300000)).to(equal("9.3m"))
    expect(NumberHelper.truncate(2000000000)).to(equal("2b"))
    expect(NumberHelper.truncate(43500000000000)).to(equal("43t"))
  }
}
