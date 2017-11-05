//
//  LaunchViewControllerTests.swift
//  TrueThatTests
//
//  Created by Ohad Navon on 02/11/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble

class LaunchViewControllerTests: BaseUITests {
  var viewController: LaunchViewController!

  func testAuthFailed() {
    // Signing out.
    App.authModule.signOut()
    // Init the view.
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "LaunchScene")
      as! LaunchViewController
    UIApplication.shared.keyWindow!.rootViewController = viewController
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    // Should segue to main view controller, as have signed out.
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(WelcomeViewController.self))
  }

  func testAuthOk() {
    // Init the view
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "LaunchScene")
      as! LaunchViewController
    UIApplication.shared.keyWindow!.rootViewController = viewController
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
    // Should segue to main view controller, as the user is authed after setUp.
    expect(UITestsHelper.currentViewController).toEventually(beAnInstanceOf(MainTabController.self))
  }
}
