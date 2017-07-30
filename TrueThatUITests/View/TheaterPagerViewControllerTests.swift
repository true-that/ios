//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

//import XCTest
//@testable import TrueThat
//import OHHTTPStubs
//import SwiftyJSON
//import Nimble
import KIF

class TheaterPagerViewControllerTests: KIFTestCase {
//  var fetchedReactables: [Reactable] = []
//  var viewController: TheaterPageViewController!
//  
//  override func setUp() {
//    super.setUp()
//
//    // Put setup code here. This method is called before the invocation of each test method in the class.
//    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
//      let stubData = try! JSON(self.fetchedReactables.map{JSON(from: $0)}).rawData()
//      self.fetchedReactables = []
//      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
//                                 headers: ["Content-Type":"application/json"])
//    }
//
//    let storyboard = UIStoryboard(name: "Main",
//                                  bundle: Bundle.main)
//    viewController = storyboard.instantiateViewController(withIdentifier: "TheaterPageViewController") as! TheaterPageViewController
//    
//    UIApplication.shared.keyWindow!.rootViewController = viewController
//    
//    // Test and load the View
//    XCTAssertNotNil(viewController.view)
//  }
//  
//  func assertDisplayed(reactable: Reactable) {
//    let app = XCUIApplication()
//    expect(app.staticTexts["directorName"].label).to(equal(reactable.director?.displayName))
//  }
//  
//  func testDisplayReactable() {
//    let reactable = Reactable(id: 1, userReaction: .sad,
//                              director: User(id: 1, firstName: "Monica", lastName: "Clinton"),
//                              reactionCounters: [.sad: 1000, .happy: 1234],
//                              created: Date(), viewed: false)
//    fetchedReactables = [reactable]
//    viewController.beginAppearanceTransition(true, animated: false)
//    viewController.endAppearanceTransition()
//    // Should display reactable eventually.
//    assertDisplayed(reactable: reactable)
//  }
  func testSomethingHere() {
    tester().tapViewWithAccessibilityLabel("hello")
  }
}
