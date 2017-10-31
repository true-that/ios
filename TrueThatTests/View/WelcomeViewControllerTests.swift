//
//  WelcomeViewControllerTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import KIF
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble

class WelcomeViewControllerTests: BaseUITests {
  var viewController: WelcomeViewController!
  let phoneNumber = "+2385472"

  override func setUp() {
    super.setUp()
    // Sign out
    App.authModule.signOut()
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(WelcomeViewController.self))
    viewController = UITestsHelper.currentViewController as! WelcomeViewController
    expect(self.viewController.view).toNot(beNil())
    // Makes sure auth delegate is set to the current view controller.
    App.authModule.delegate = viewController
  }

  func testSignUp() {
    UITestsHelper.triggeringViewAppearance(viewController)
    tester().tapView(withAccessibilityLabel: "sign up")
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(OnBoardingViewController.self))
    UITestsHelper.currentViewController!.dismiss(animated: false, completion: nil)
  }

  func testAlreadyAuthOk() {
    App.authModule.current = User(id: 1, firstName: "Mr", lastName: "Navon", deviceId: App.deviceModule.deviceId,
                                  phoneNumber: phoneNumber)
    UITestsHelper.triggeringViewAppearance(viewController)
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(TheaterViewController.self))
  }

  func testSignIn() {
    // Signs up a user
    let responded = User(id: 1, firstName: "dellores", lastName: "hidyhoe",
                         deviceId: App.deviceModule.deviceId, phoneNumber: phoneNumber)
    stub(condition: isPath(AuthApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON(responded.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    UITestsHelper.triggeringViewAppearance(viewController)
    tester().tapView(withAccessibilityLabel: "sign in")
    expect(App.authModule.isAuthOk).toEventually(beTrue())
  }

  func testWarningLabel() {
    // Sets up a bad backend
    stub(condition: isPath(AuthApi.path)) { _ -> OHHTTPStubsResponse in
      let stubData = try! JSON([:]).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 500,
                                 headers: ["Content-Type": "application/json"])
    }
    UITestsHelper.triggeringViewAppearance(viewController)
    // Sign in should fail because there is no proper background
    tester().tapView(withAccessibilityLabel: "sign in")
    // Failure dialog should appear
    tester().tapView(withAccessibilityLabel: WelcomeViewController.failedSignInDialogOkAction)
  }
}
