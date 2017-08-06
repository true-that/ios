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
    fakeAuthModule.signOut()
    
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "WelcomeScene") as! WelcomeViewController
    UIApplication.shared.keyWindow!.rootViewController = viewController
    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
  }
  
  func testStartSignUp() {
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    tester().tapView(withAccessibilityLabel: "sign up")
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(OnBoardingViewController.self))
  }
  
  func testAlreadyAuthOk() {
    fakeAuthModule.current = User(id: 1, firstName: "Mr", lastName: "Navon", deviceId: "345345")
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    fakeAuthModule.auth()
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(TheaterViewController.self))
  }
  
  func testSignIn() {
    // Signs up a user
    let responded = User(id: 1, firstName: "dellores", lastName: "hidyhoe", deviceId: App.deviceModule.deviceId)
    stub(condition: isPath(AuthApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(responded.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    fakeAuthModule.delegate = nil
    fakeAuthModule.signUp(fullName: "dellores hidyhoe")
    expect(self.fakeAuthModule.isAuthOk).toEventually(beTrue())
    // Signs out, but keeps session data
    fakeAuthModule.current = nil
    expect(self.fakeAuthModule.isAuthOk).to(beFalse())
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    tester().tapView(withAccessibilityLabel: "sign in")
    expect(self.fakeAuthModule.isAuthOk).toEventually(beTrue())
  }
  
  func testWarningLabel() {
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    App.authModule.auth()
    expect(self.viewController.errorLabel.isHidden).to(beFalse())
  }
}
