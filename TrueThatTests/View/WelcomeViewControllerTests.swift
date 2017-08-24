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

class WelcomeViewControllerTests : BaseUITests {
  var viewController: WelcomeViewController!
  
  override func setUp() {
    super.setUp()
    if UITestsHelper.currentViewController != nil
      && type(of: UITestsHelper.currentViewController!) != WelcomeViewController.self {
      // Wait for app to load
      expect(UITestsHelper.currentViewController!)
        .toEventually(beAnInstanceOf(TheaterViewController.self))
      expect(UITestsHelper.currentViewController!.view).toEventuallyNot(beNil())
    }
    // Sign out
    App.authModule.signOut()
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(WelcomeViewController.self))
    viewController = UITestsHelper.currentViewController as! WelcomeViewController
    expect(App.authModule.delegate).toEventually(beIdenticalTo(self.viewController))
  }
  
  func testStartSignUp() {
    tester().tapView(withAccessibilityLabel: "sign up")
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(OnBoardingViewController.self))
  }
  
  func testAlreadyAuthOk() {
    App.authModule.current = User(id: 1, firstName: "Mr", lastName: "Navon", deviceId: "345345")
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    App.authModule.auth()
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(TheaterViewController.self))
  }
  
  func testSignIn() {
    // Signs up a user
    let responded = User(id: 1, firstName: "dellores", lastName: "hidyhoe",
                         deviceId: App.deviceModule.deviceId)
    stub(condition: isPath(AuthApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(responded.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    App.authModule.delegate = nil
    App.authModule.signUp(fullName: "dellores hidyhoe")
    expect(App.authModule.isAuthOk).toEventually(beTrue())
    // Signs out, but keeps session data
    App.authModule.current = nil
    expect(App.authModule.isAuthOk).to(beFalse())
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    tester().tapView(withAccessibilityLabel: "sign in")
    expect(App.authModule.isAuthOk).toEventually(beTrue())
  }
  
  func testWarningLabel() {
    App.authModule.signIn()
    expect(self.viewController.errorLabel.isHidden).toEventually(beFalse())
  }
}
