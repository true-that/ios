//
//  ShortMediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import AVFoundation
import Nimble

class ShortMediaViewControllerTests : BaseUITests {
  var viewController: ShortMediaViewController!
  let short = Short(id: 3, userReaction: .happy,
                    director: User(id: 1, firstName: "Emma", lastName: "Watson", deviceId: "iphone2"),
                    reactionCounters: [.happy: 5000, .sad: 34], created: Date(),
                    viewed: false,
                    videoUrl: URL(string: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4"))
  
  override func setUp() {
    super.setUp()
    
    viewController = ShortMediaViewController.instantiate(short)
    
    UIApplication.shared.keyWindow!.rootViewController = viewController
    
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    // Mutes the video
    viewController.player?.volume = 0
  }
  
  func testVideoIsPlaying() {
    expect(self.viewController.player?.timeControlStatus)
      .toEventually(equal(.playing), timeout: 5.0)
    expect(self.viewController.player?.currentTime())
      .toEventuallyNot(equal(kCMTimeZero))
  }
  
  func testVideoIsLooping() {
    expect(self.viewController.player?.currentTime())
      .toEventuallyNot(equal(kCMTimeZero), timeout: 5.0)
    let currentTime = viewController.player?.currentTime()
    expect(currentTime!.seconds > self.viewController.player!.currentTime().seconds)
      .toEventually(beTrue(), timeout: 5.0)
  }
  
  func testTouchEventControl() {
//    expect(4).toEventually(equal(8), timeout: 40.0)
    // Wait for video to start
    expect(self.viewController.player?.currentTime())
      .toEventuallyNot(equal(kCMTimeZero), timeout: 5.0)
    let currentTime = viewController.player!.currentItem!.currentTime().seconds
    // Pausing video with tap
    tester().longPressView(withAccessibilityLabel: "short video", duration: 1.0)
    // Video should resume
    expect(self.viewController.player!.currentTime().seconds)
      .toNot(equal(currentTime))
    // Asserting a pause did occur.
    expect(self.viewController.player!.currentItem!.currentTime().seconds - currentTime < 0.9).to(beTrue())
  }
}
