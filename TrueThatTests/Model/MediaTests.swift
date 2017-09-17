//
//  MediaTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 10/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import TrueThat
import Nimble

class MediaTests: XCTestCase {
  func testJsonSerialization() {
    var media = Media(id: 0, url: "a.com")
    expect(media).to(equal(Media(json: JSON(from: media))))
    // Test proper serialization and deserialization of sub types
    media = Photo(id: 0, url: "a.com")
    expect(media).to(equal(Media.instantiate(with: JSON(from: media))))
    expect(media).to(beAnInstanceOf(Photo.self))
  }
}
