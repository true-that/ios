//
//  TheaterViewModelTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble


class TheaterViewModelTests: BaseViewModelTests {
  var fetchedReactables: [Reactable] = []
  var viewModel: TheaterViewModel!
  var viewModelDelegate: FakeTheaterDelegate!
  
  override func setUp() {
    super.setUp()
    stub(condition: isPath(TheaterApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(self.fetchedReactables.map{JSON(from: $0)}).rawData()
      self.fetchedReactables = []
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    viewModel = TheaterViewModel()
    viewModelDelegate = FakeTheaterDelegate()
    viewModel.delegate = viewModelDelegate
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testDisplayReactable() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "Monica", lastName: "Clinton"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    fetchedReactables = [reactable]
    viewModel.fetchingData()
    expect(self.viewModel.reactables).toEventually(haveCount(1))
    expect(self.viewModel.reactables[0]).to(equal(reactable))
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
    expect(self.viewModelDelegate.lastUpdate).to(haveCount(1))
    expect(self.viewModelDelegate.lastUpdate?[0]).to(equal(reactable))
  }
  
  func testEmptyFetch() {
    fetchedReactables = []
    viewModel.fetchingData()
    expect(self.viewModel.reactables).toNotEventually(haveCount(1))
    expect(self.viewModelDelegate.currentIndex == nil).toNotEventually(beFalse())
  }
  
  func testNavigateNext() {
    let reactable1 = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "Monica", lastName: "Clinton"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    let reactable2 = Reactable(id: 2, userReaction: .happy,
                              director: User(id: 1, firstName: "Bill", lastName: "Lewinsky"),
                              reactionCounters: [.sad: 5000, .happy: 34],
                              created: Date(), viewed: true)
    fetchedReactables = [reactable1, reactable2]
    viewModel.fetchingData()
    expect(self.viewModel.reactables).toEventually(haveCount(2))
    expect(self.viewModel.reactables[0]).to(equal(reactable1))
    expect(self.viewModel.reactables[1]).to(equal(reactable2))
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
    expect(self.viewModelDelegate.lastUpdate).to(haveCount(2))
    expect(self.viewModelDelegate.lastUpdate).to(equal(self.viewModel.reactables))
    // Navigating next
    expect(self.viewModel.navigateNext()).to(equal(1))
    expect(self.viewModel.currentIndex).to(equal(1))
    // Should not update delegate index
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
    // Cant navigate outside of limits
    expect(self.viewModel.navigateNext()).to(beNil())
  }
  
  func testNavigateNextFetchNewData() {
    let reactable1 = Reactable(id: 1, userReaction: .sad,
                               director: User(id: 1, firstName: "Monica", lastName: "Clinton"),
                               reactionCounters: [.sad: 1000, .happy: 1234],
                               created: Date(), viewed: false)
    let reactable2 = Reactable(id: 2, userReaction: .happy,
                               director: User(id: 1, firstName: "Bill", lastName: "Lewinsky"),
                               reactionCounters: [.sad: 5000, .happy: 34],
                               created: Date(), viewed: true)
    fetchedReactables = [reactable1]
    viewModel.fetchingData()
    expect(self.viewModel.reactables).toEventually(haveCount(1))
    expect(self.viewModel.currentIndex).to(equal(0))
    // Prepares new fetch
    fetchedReactables = [reactable2]
    // Navigating next (should not alter index)
    expect(self.viewModel.navigateNext()).to(beNil())
    expect(self.viewModel.currentIndex).to(equal(0))
    expect(self.viewModel.reactables).toEventually(haveCount(2))
    // Should navigate as soon as new reactables are fetched
    expect(self.viewModel.currentIndex).to(equal(1))
    expect(self.viewModelDelegate.currentIndex).to(equal(1))
    
  }
  
  func testNavigatePrevious() {
    let reactable1 = Reactable(id: 1, userReaction: .sad,
                               director: User(id: 1, firstName: "Monica", lastName: "Clinton"),
                               reactionCounters: [.sad: 1000, .happy: 1234],
                               created: Date(), viewed: false)
    let reactable2 = Reactable(id: 2, userReaction: .happy,
                               director: User(id: 1, firstName: "Bill", lastName: "Lewinsky"),
                               reactionCounters: [.sad: 5000, .happy: 34],
                               created: Date(), viewed: true)
    fetchedReactables = [reactable1, reactable2]
    viewModel.fetchingData()
    expect(self.viewModel.reactables).toEventually(haveCount(2))
    // Navigating next
    expect(self.viewModel.navigateNext()).to(equal(1))
    // NAvigating previous
    expect(self.viewModel.navigatePrevious()).to(equal(0))
    expect(self.viewModel.currentIndex).to(equal(0))
    expect(self.viewModelDelegate.currentIndex).to(equal(0))
    // Cant navigate outside of limits
    expect(self.viewModel.navigatePrevious()).to(beNil())
  }
  
  class FakeTheaterDelegate: TheaterDelegate {
    var currentIndex: Int?
    var lastUpdate: [Reactable]?
    
    func display(at index: Int) {
      currentIndex = index
    }
    
    func scroll(to index: Int) {
      display(at: index)
    }
    
    func updatingData(with newReactables: [Reactable]) {
      lastUpdate = newReactables
    }
  }
}
