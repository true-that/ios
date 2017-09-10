//
//  ScenesPageViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift

class ScenesPageViewModel {
  public let nonFoundHidden = MutableProperty(true)
  public let loadingImageHidden = MutableProperty(false)
  var scenes = [Scene]()
  var delegate: ScenesPageDelegate!
  var fetchingDelegate: FetchScenesDelegate!
  var currentIndex = 0
  
  /// Updates `currentIndex` to previous scene, if not already at the first one.
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
  
  /// Updates `currentIndex` to previous scene, if not already at the last one.
  ///
  /// - Returns: the updated `currentIndex`, or nil if no update was made.
  public func navigateNext() -> Int? {
    let nextIndex = currentIndex + 1
    
    // User is on the last view controller and swiped right.
    guard scenes.count != nextIndex else {
      fetchingData()
      return nil
    }
    
    currentIndex = nextIndex
    return currentIndex
  }
  
  /// Fetch new scenes from our backend.
  public func fetchingData() {
    App.log.debug("fetching scenes")
    if scenes.isEmpty {
      loadingImageHidden.value = false
    }
    fetchingDelegate.fetchingProducer()
      .on(value: { self.adding($0) })
      .on(failed: {error in
        App.log.report("Failed fetch request: \(error)", withError: error)
        self.loadingImageHidden.value = true
        if self.scenes.isEmpty {
          self.nonFoundHidden.value = false
        }
      })
      .start()
  }
  
  /// Append the fetched scenes to `scenes` and notify the view controller.
  ///
  /// - Parameter newScenes: freshly baked scenes, obvuala!
  private func adding(_ newScenes: [Scene]) {
    loadingImageHidden.value = true
    if newScenes.count > 0 {
      let shouldScroll = scenes.count > 0
      currentIndex = scenes.count
      scenes += newScenes
      delegate.updatingData(with: newScenes)
      if (shouldScroll) {
        delegate.scroll(to: currentIndex)
      } else {
        delegate.display(at: currentIndex)
      }
    } else if scenes.count == 0 {
      nonFoundHidden.value = false
    }
  }
}

protocol ScenesPageDelegate {
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
  /// - Parameter newScenes: new data models to create view controllers from.
  func updatingData(with newScenes: [Scene])
}

protocol FetchScenesDelegate {
  /// - Returns: a signal producer to fetch scenes from our backend.
  @discardableResult func fetchingProducer() -> SignalProducer<[Scene], NSError>
}
