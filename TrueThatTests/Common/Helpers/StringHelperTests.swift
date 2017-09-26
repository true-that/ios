//
//  StringHelperTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import Nimble

class StringHelperTests: XCTestCase {
  func testExtractFirstName() {
    expect(StringHelper.extractFirstName(of: "   a")).to(equal("a"))
    expect(StringHelper.extractFirstName(of: "a b")).to(equal("a"))
    expect(StringHelper.extractFirstName(of: "  Asta   lA visTA")).to(equal("asta"))
  }

  func testExtractLastName() {
    expect(StringHelper.extractLastName(of: "a")).to(equal(""))
    expect(StringHelper.extractLastName(of: "a     b   c")).to(equal("b c"))
    expect(StringHelper.extractLastName(of: "Asta lA visTA")).to(equal("la vista"))
  }

  func testIsValidName() {
    expect(StringHelper.isValid(fullName: "a pineapple")).to(beFalse())
    expect(StringHelper.isValid(fullName: "pen 11 pineapple")).to(beFalse())
    expect(StringHelper.isValid(fullName: "pen p")).to(beFalse())
    expect(StringHelper.isValid(fullName: "apple pen")).to(beTrue())
    expect(StringHelper.isValid(fullName: "pen PINEapple apple pen")).to(beTrue())
  }

  func testIsAlpha() {
    expect(StringHelper.isAlpha("a")).to(beTrue())
    expect(StringHelper.isAlpha("a b")).to(beTrue())
    expect(StringHelper.isAlpha("a 1 b")).to(beFalse())
    expect(StringHelper.isAlpha("a23b")).to(beFalse())
    expect(StringHelper.isAlpha("23b")).to(beFalse())
  }
}
