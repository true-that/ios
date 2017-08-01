//
//  ReactableViewModelTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import Nimble


class ReactableViewModelTests: XCTestCase {
  var viewModel: ReactableViewModel!
  
  func testDisplayReactable() {
    let reactable = Reactable(id: 1, userReaction: .sad,
                              director: User(id: 1, firstName: "Mr", lastName: "Robot"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(), viewed: false)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.model).to(equal(reactable))
    expect(self.viewModel.directorName.value).to(equal(reactable.director?.displayName))
    expect(self.viewModel.timeAgo.value).to(equal("now"))
    expect(self.viewModel.reactionsCount.value).to(equal("2.2k"))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.sad.emoji))
  }
  
  func testDisplayReactable_commonReactionDisplayed() {
    let reactable = Reactable(id: 1, userReaction: nil,
                              director: User(id: 1, firstName: "Wallstreet", lastName: "Wolf"),
                              reactionCounters: [.sad: 1000, .happy: 1234],
                              created: Date(timeIntervalSinceNow: -60), viewed: false)
    viewModel = ReactableViewModel(with: reactable)
    expect(self.viewModel.model).to(equal(reactable))
    expect(self.viewModel.directorName.value).to(equal(reactable.director?.displayName))
    expect(self.viewModel.timeAgo.value).to(equal("1m ago"))
    expect(self.viewModel.reactionsCount.value).to(equal("2.2k"))
    expect(self.viewModel.reactionEmoji.value).to(equal(Emotion.happy.emoji))
  }
}

