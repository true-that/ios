//
//  MainTabControllerTests.swift
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

class MainTabControllerTests: BaseUITests {
  var viewController: MainTabController!

  override func setUp() {
    super.setUp()

    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    viewController = storyboard.instantiateViewController(withIdentifier: "MainScene")
      as! MainTabController

    UIApplication.shared.keyWindow!.rootViewController = viewController

    // Test and load the View
    expect(self.viewController.view).toNot(beNil())
  }

  func testNavigation() {
    // expect current index is launch index
    expect(self.viewController.selectedIndex).toEventually(equal(MainTabController.launchIndex))
    // navigate to theater
    viewController.selectedIndex = MainTabController.theaterIndex
    // navigate to studio
    viewController.selectedIndex = MainTabController.studioIndex
    // navigate to repertoire
    viewController.selectedIndex = MainTabController.repertoireIndex
  }
}
