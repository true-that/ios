//
//  VideoViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import AVFoundation
import Nimble

class VideoViewControllerTests: BaseUITests {
  var viewController: VideoViewController!
  var delegate: TestsMediaViewControllerDelegate!
  let video = Video(id: 0, url: "https://storage.googleapis.com/truethat-test-studio/testing/Ohad_wink_compressed.mp4")

  override func setUp() {
    super.setUp()

    delegate = TestsMediaViewControllerDelegate()
    viewController = MediaViewController.instantiate(with: video) as! VideoViewController
    viewController.delegate = delegate

    UIApplication.shared.keyWindow!.rootViewController = viewController

    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    // Mutes the video
    viewController.player?.volume = 0
    // Triggers didShow
    viewController.viewDidShow()
  }

  func testVideoIsPlaying() {
    expect(self.viewController.player?.timeControlStatus)
      .toEventually(equal(.playing), timeout: 5.0)
    expect(self.viewController.player?.currentTime())
      .toEventuallyNot(equal(kCMTimeZero))
    expect(self.delegate.mediaDidDownload).to(beTrue())
    expect(self.delegate.loaderHidden).to(beTrue())
  }

  func testVideoIsLooping() {
    expect(self.viewController.player?.currentTime())
      .toEventuallyNot(equal(kCMTimeZero), timeout: 5.0)
    let currentTime = viewController.player?.currentTime()
    expect(currentTime!.seconds > self.viewController.player!.currentTime().seconds)
      .toEventually(beTrue(), timeout: 5.0)
  }

  func testTouchEventControl() {
    // Wait for video to start
    expect(self.viewController.player?.currentTime())
      .toEventuallyNot(equal(kCMTimeZero), timeout: 5.0)
    let currentTime = viewController.player!.currentItem!.currentTime().seconds
    // Pausing video with tap
    tester().longPressView(withAccessibilityLabel: "video", duration: 1.0)
    // Video should resume
    expect(self.viewController.player!.currentTime().seconds)
      .toNot(equal(currentTime))
    // Asserting a pause did occur.
    expect(self.viewController.player!.currentItem!.currentTime().seconds - currentTime < 0.9).to(beTrue())
  }

  class TestsMediaViewControllerDelegate: MediaViewControllerDelegate {
    var mediaDidDownload: Bool?
    var loaderHidden: Bool?
    var finished = false

    func didDownloadMedia() {
      mediaDidDownload = true
    }

    func showLoader() {
      loaderHidden = false
    }

    func hideLoader() {
      loaderHidden = true
    }

    func didFinish() {
      finished = true
    }
  }
}
