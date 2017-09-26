//
//  VideoEncoderTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 24/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import ReactiveSwift
import Nimble

class VideoEncoderTests: BaseUITests {
  let url = URL(fileURLWithPath: "TrueThatTests/ViewModel/TestData/ohad-wink.mov",
                                  relativeTo: BaseTests.baseDir)
  
  func testEncodeSuccessful() {
    let filePath = VideoEncoder.encodeVid(videoURL: url)
    expect(FileManager.default.fileExists(atPath: filePath.path)).toEventually(beTrue())
  }
}
