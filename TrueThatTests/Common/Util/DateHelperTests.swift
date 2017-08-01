//
//  DateHelperTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import Nimble

class DateHelperTests: XCTestCase {
  func testUtcDateFromDate() {
    let expected = "1970-Jan-01T00:00:01.000+0000"
    expect(DateHelper.utcDate(fromDate: Date(timeIntervalSince1970: 1))).to(equal(expected))
  }
  
  func testUtcDateFromString() {
    expect(DateHelper.utcDate(fromString: "1970-Jan-01T00:00:01.000+0000"))
      .to(equal(Date(timeIntervalSince1970: 1)))
  }
  
  func testTimeAgo() {
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: 0))).to(equal(DateHelper.nowText))
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: -20))).to(equal(DateHelper.nowText))
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: -60))).to(equal("1m ago"))
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: -119))).to(equal("1m ago"))
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: -60 * 10))).to(equal("10m ago"))
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: -60 * 60))).to(equal("1h ago"))
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: -60 * 60 * 24))).to(equal("1d ago"))
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: -60 * 60 * 24 * 30))).to(equal("1mon ago"))
    expect(DateHelper.truncatedTimeAgo(from: Date(timeIntervalSinceNow: -60 * 60 * 24 * 30 * 13))).to(equal("1y ago"))
  }
}


