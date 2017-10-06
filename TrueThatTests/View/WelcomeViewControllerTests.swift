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
    if UITestsHelper.currentViewController != nil
      && type(of: UITestsHelper.currentViewController!) != WelcomeViewController.self {
      let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
      viewController = storyboard.instantiateViewController(withIdentifier: "WelcomeScene")
        as! WelcomeViewController

      UIApplication.shared.keyWindow!.rootViewController = viewController

      // Test and load the View
      expect(self.viewController.view).toNot(beNil())
    }
    // Sign out
    App.authModule.signOut()
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(WelcomeViewController.self))
    viewController = UITestsHelper.currentViewController as! WelcomeViewController
    expect(self.viewController.view).toNot(beNil())
    App.authModule.delegate = viewController
  }

  func testSignUp() {
    tester().tapView(withAccessibilityLabel: "sign up")
    expect(UITestsHelper.currentViewController!)
      .toEventually(beAnInstanceOf(OnBoardingViewController.self))
  }

  func testAlreadyAuthOk() {
    App.authModule.current = User(id: 1, firstName: "Mr", lastName: "Navon", deviceId: "345345",
                                  phoneNumber: phoneNumber)
    // Trigger viewDidAppear
    viewController.beginAppearanceTransition(true, animated: false)
    App.authModule.auth()
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
    App.authModule.delegate = nil
    App.authModule.signUp(fullName: "dellores hidyhoe", phoneNumber: phoneNumber)
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
    App.authModule.signOut()
    App.authModule.signIn()
    expect(self.viewController.errorLabel.isHidden).toEventually(beFalse())
  }
}
