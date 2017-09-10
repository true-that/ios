//
//  JSONExtensionsTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 22/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import Nimble
import SwiftyJSON

class JSONExtensionsTests: XCTestCase {
  func testInitFromBaseModel() {
    let model = TestModel(a: 1)
    expect(JSON(from: model)["a"]).to(equal(1))
  }
  
  fileprivate class TestModel: BaseModel {
    var a: Int?

    init(a: Int?) {
      super.init()
      self.a = a
    }
    
    required init(json: JSON) {
      super.init(json: json)
      a = json["a"].int
    }
    
    override func toDictionary() -> [String : Any] {
      var dict = super.toDictionary()
      dict["a"] = a
      return dict
    }
  }
}
