//
//  ScenesPageViewModelTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import ReactiveSwift
import SwiftyJSON
import Nimble

class ScenesPageViewModelTests: BaseTests {
  var fetchedScenes: [Scene] = []
  var viewModel: ScenesPageViewModel!
  var viewModelDelegate: FakeScenesPageDelegate!

  override func setUp() {
    super.setUp()
    stub(condition: isPath(TheaterApi.path)) { request -> OHHTTPStubsResponse in
      expect(User(json: JSON(Data(fromStream: request.httpBodyStream!))))
        .to(equal(App.authModule.current!))
      let stubData = try! JSON(self.fetchedScenes.map { JSON(from: $0) }).rawData()
      self.fetchedScenes = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    viewModel = ScenesPageViewModel()
    viewModelDelegate = FakeScenesPageDelegate()
    viewModel.delegate = viewModelDelegate
    viewModel.fetchingDelegate = TestsFetchScenesDelegate()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testDisplayScene() {
    let scene = Scene(id: 1, director: User(id: 1, firstName: "Todo", lastName: "Bom", deviceId: "android"),
                      reactionCounters: [.disgust: 1000, .happy: 1234],
                      created: Date(), mediaNodes: nil, edges: nil)
    fetchedScenes = [scene]
    viewModel.fetchingData()
    // Loading image should now be visible
    expect(self.viewModel.loadingImageHidden.value).to(beFalse())
    // Test proper scene displayed
    expect(self.viewModel.scenes).toEventually(haveCount(1))
    expect(self.viewModel.scenes[0]).to(equal(scene))
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
    expect(self.viewModelDelegate.lastUpdate).to(haveCount(1))
    expect(self.viewModelDelegate.lastUpdate?[0]).to(equal(scene))
    expect(self.viewModel.nonFoundHidden.value).to(beTrue())
    // Loading image should now be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
  }

  func testEmptyFetch() {
    fetchedScenes = []
    viewModel.fetchingData()
    // Loading image should now be visible
    expect(self.viewModel.loadingImageHidden.value).to(beFalse())
    // No scenes should be displayed
    expect(self.viewModel.scenes).toNotEventually(haveCount(1))
    expect(self.viewModelDelegate.currentIndex == nil).toNotEventually(beFalse())
    expect(self.viewModel.nonFoundHidden.value).toEventually(beFalse())
    // Loading image should now be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
  }

  func testFailedFetch() {
    // Set up an ill backend
    stub(condition: isPath(TheaterApi.path)) { request -> OHHTTPStubsResponse in
      expect(User(json: JSON(Data(fromStream: request.httpBodyStream!))))
        .to(equal(App.authModule.current!))
      return OHHTTPStubsResponse(data: Data(), statusCode: 500,
                                 headers: ["Content-Type": "application/json"])
    }
    let scene = Scene(id: 1, director: User(id: 1, firstName: "Todo", lastName: "Bom", deviceId: "android"),
                      reactionCounters: [.disgust: 1000, .happy: 1234],
                      created: Date(), mediaNodes: nil, edges: nil)
    fetchedScenes = [scene]
    viewModel.fetchingData()
    // Loading image should now be visible
    expect(self.viewModel.loadingImageHidden.value).to(beFalse())
    // No scenes should be displayed
    expect(self.viewModel.scenes).toNotEventually(haveCount(1))
    expect(self.viewModelDelegate.currentIndex == nil).toNotEventually(beFalse())
    expect(self.viewModel.nonFoundHidden.value).toEventually(beFalse())
    // Loading image should now be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
  }

  func testNavigateNext() {
    let scene1 = Scene(id: 1, director: User(id: 1, firstName: "Todo", lastName: "Bom", deviceId: "android"),
                       reactionCounters: [.disgust: 1000, .happy: 1234],
                       created: Date(), mediaNodes: nil, edges: nil)
    let scene2 = Scene(id: 2, director: User(id: 1, firstName: "Dubi", lastName: "Gal", deviceId: "iphone"),
                       reactionCounters: [.disgust: 5000, .happy: 34],
                       created: Date(), mediaNodes: nil, edges: nil)
    fetchedScenes = [scene1, scene2]
    viewModel.fetchingData()
    expect(self.viewModel.scenes).toEventually(haveCount(2))
    expect(self.viewModel.scenes[0]).to(equal(scene1))
    expect(self.viewModel.scenes[1]).to(equal(scene2))
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
    expect(self.viewModelDelegate.lastUpdate).to(haveCount(2))
    expect(self.viewModelDelegate.lastUpdate).to(equal(self.viewModel.scenes))
    // Navigating next
    expect(self.viewModel.navigateNext()).to(equal(1))
    expect(self.viewModel.currentIndex).to(equal(1))
    // Should not update delegate index
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
    // Cant navigate outside of limits
    expect(self.viewModel.navigateNext()).to(beNil())
  }

  func testNavigateNextFetchNewData() {
    let scene1 = Scene(id: 1, director: User(id: 1, firstName: "Todo", lastName: "Bom", deviceId: "android"),
                       reactionCounters: [.disgust: 1000, .happy: 1234],
                       created: Date(), mediaNodes: nil, edges: nil)
    let scene2 = Scene(id: 2, director: User(id: 1, firstName: "Dubi", lastName: "Gal", deviceId: "iphone"),
                       reactionCounters: [.disgust: 5000, .happy: 34],
                       created: Date(), mediaNodes: nil, edges: nil)
    fetchedScenes = [scene1]
    viewModel.fetchingData()
    expect(self.viewModel.scenes).toEventually(haveCount(1))
    expect(self.viewModel.currentIndex).to(equal(0))
    // Prepares new fetch
    fetchedScenes = [scene2]
    // Navigating next (should not alter index)
    expect(self.viewModel.navigateNext()).to(beNil())
    expect(self.viewModel.currentIndex).to(equal(0))
    // Loading image should now be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
    expect(self.viewModel.scenes).toEventually(haveCount(2))
    // Should navigate as soon as new scenes are fetched
    expect(self.viewModel.currentIndex).to(equal(1))
    expect(self.viewModelDelegate.currentIndex).to(equal(1))
  }

  func testDontFetchDuplicateIds() {
    let scene = Scene(id: 1, director: User(id: 1, firstName: "Todo", lastName: "Bom", deviceId: "android"),
                      reactionCounters: [.disgust: 1000, .happy: 1234],
                      created: Date(), mediaNodes: nil, edges: nil)
    fetchedScenes = [scene]
    viewModel.fetchingData()
    expect(self.viewModel.scenes).toEventually(haveCount(1))
    expect(self.viewModel.currentIndex).to(equal(0))
    // Prepares new fetch
    scene.director!.id! += 1
    fetchedScenes = [scene]
    // Navigating next (should not alter index)
    expect(self.viewModel.navigateNext()).to(beNil())
    expect(self.viewModel.currentIndex).to(equal(0))
    // Loading image should now be hidden
    expect(self.viewModel.loadingImageHidden.value).to(beTrue())
    expect(self.viewModel.scenes).toNotEventually(haveCount(2))
    // Should not navigate
    expect(self.viewModel.currentIndex).to(equal(0))
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
  }

  func testNavigatePrevious() {
    let scene1 = Scene(id: 1, director: User(id: 1, firstName: "Todo", lastName: "Bom", deviceId: "android"),
                       reactionCounters: [.disgust: 1000, .happy: 1234],
                       created: Date(), mediaNodes: nil, edges: nil)
    let scene2 = Scene(id: 2, director: User(id: 1, firstName: "Dubi", lastName: "Gal", deviceId: "iphone"),
                       reactionCounters: [.disgust: 5000, .happy: 34],
                       created: Date(), mediaNodes: nil, edges: nil)
    fetchedScenes = [scene1, scene2]
    viewModel.fetchingData()
    expect(self.viewModel.scenes).toEventually(haveCount(2))
    // Navigating next
    expect(self.viewModel.navigateNext()).to(equal(1))
    // NAvigating previous
    expect(self.viewModel.navigatePrevious()).to(equal(0))
    expect(self.viewModel.currentIndex).to(equal(0))
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
    // Cant navigate outside of limits
    expect(self.viewModel.navigatePrevious()).to(beNil())
  }

  class FakeScenesPageDelegate: ScenesPageDelegate {
    var currentIndex: Int?
    var lastUpdate: [Scene]?

    func display(at index: Int) {
      currentIndex = index
    }

    func scroll(to index: Int) {
      display(at: index)
    }

    func updatingData(with newScenes: [Scene]) {
      lastUpdate = newScenes
    }
  }

  class TestsFetchScenesDelegate: FetchScenesDelegate {
    @discardableResult func fetchingProducer() -> SignalProducer<[Scene], NSError> {
      return TheaterApi.fetchScenes(for: App.authModule.current!)
    }
  }
}
