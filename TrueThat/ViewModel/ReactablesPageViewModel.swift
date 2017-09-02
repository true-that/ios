//
//  ReactablesPageViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift

class ReactablesPageViewModel {
  public let nonFoundHidden = MutableProperty(true)
  public let loadingImageHidden = MutableProperty(false)
  var reactables = [Reactable]()
  var delegate: ReactablesPageDelegate!
  var fetchingDelegate: FetchReactablesDelegate!
  var currentIndex = 0
  
  /// Updates `currentIndex` to previous reactable, if not already at the first one.
  ///
  /// - Returns: the updated `currentIndex`, or nil if no update was made.
  public func navigatePrevious() -> Int? {
    let previousIndex = currentIndex - 1
    
    // User is on the first view controller and swiped left.
    guard previousIndex >= 0 else {
      return nil
    }
    currentIndex = previousIndex
    return currentIndex
  }
  
  /// Updates `currentIndex` to previous reactable, if not already at the last one.
  ///
  /// - Returns: the updated `currentIndex`, or nil if no update was made.
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
  
  /// Fetch new reactables from our backend.
  public func fetchingData() {
    if reactables.isEmpty {
      loadingImageHidden.value = false
    }
    fetchingDelegate.fetchingProducer()
      .on(value: { self.adding($0) })
      .on(failed: {error in
        App.log.error("Failed fetch request: \(error)")
        self.loadingImageHidden.value = true
        if self.reactables.isEmpty {
          self.nonFoundHidden.value = false
        }
      })
      .start()
  }
  
  /// Append the fetched reactables to `reactables` and notify the view controller.
  ///
  /// - Parameter newReactables: freshly baked reactables, obvuala!
  private func adding(_ newReactables: [Reactable]) {
    loadingImageHidden.value = true
    if newReactables.count > 0 {
      let shouldScroll = reactables.count > 0
      currentIndex = reactables.count
      reactables += newReactables
      delegate.updatingData(with: newReactables)
      if (shouldScroll) {
        delegate.scroll(to: currentIndex)
      } else {
        delegate.display(at: currentIndex)
      }
    } else if reactables.count == 0 {
      nonFoundHidden.value = false
    }
  }
}

protocol ReactablesPageDelegate {
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

protocol FetchReactablesDelegate {
  /// - Returns: a signal producer to fetch reactables from our backend.
  @discardableResult func fetchingProducer() -> SignalProducer<[Reactable], NSError>
}
