//
//  TheaterViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift

class TheaterViewModel {
  var reactables = [Reactable]()
  var delegate: TheaterDelegate!
  var currentIndex = 0
  var authModule = AuthModule()
  
  public func didAppear() {
    if (reactables.count == 0) {
      fetchingData()
    }
  }
  
  public func navigatePrevious() -> Int? {
    let previousIndex = currentIndex - 1
    
    // User is on the first view controller and swiped left.
    guard previousIndex >= 0 else {
      return nil
    }
    currentIndex = previousIndex
    return currentIndex
  }
  
  public func navigateNext() -> Int? {
    let nextIndex = currentIndex + 1
    
    // User is on the last view controller and swiped right.
    guard reactables.count != nextIndex else {
      fetchingData()
      return nil
    }
    
    currentIndex = nextIndex
    return currentIndex
  }
  
  public func fetchingData() {
    _ = TheaterApi.fetchReactables(for: authModule.currentUser)
      .on(value: { self.adding($0) })
      .on(failed: {error in
        print(error)
      })
    .start()
  }
  
  private func adding(_ newReactables: [Reactable]) {
    if (newReactables.count > 0) {
      let shouldScroll = reactables.count > 0
      currentIndex = reactables.count
      reactables += newReactables
      delegate.updatingData(with: newReactables)
      if (shouldScroll) {
        delegate.scroll(to: currentIndex)
      } else {
        delegate.display(at: currentIndex)
      }
    }
  }
}

protocol TheaterDelegate: class {
  /// Displays the view controller at the given index. Should be used when no view controllers have
  /// already been displayed.
  ///
  /// - Parameter index: to display
  func display(at index: Int)
  
  /// Scrolls the view controller at the given index. Should be used when a view controller have
  /// already been displayed.
  ///
  /// - Parameter index: to scroll to
  func scroll(to index: Int)
  
  /// Updates the data source of the page view controller
  ///
  /// - Parameter newReactables: new data models to create view controllers from.
  func updatingData(with newReactables: [Reactable])
}
