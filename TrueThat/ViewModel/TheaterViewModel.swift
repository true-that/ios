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
//  var reactableViewModels = MutableProperty<[ReactableViewModel]>([ReactableViewModel]())
  var viewModels = [ReactableViewModel]()
  var delegate: TheaterDelegate!
  var currentIndex = 0
  var authModule = AuthModule()
  
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
    guard viewModels.count != nextIndex else {
      fetchingData()
      return nil
    }
    
    currentIndex = nextIndex
    return currentIndex
  }
  
  public func fetchingData() {
    _ = TheaterApi.fetchReactables(for: authModule.currentUser)
      .on(value: { self.add(reactables: $0) })
      .on(failed: {error in
        print(error)
      })
  }
  
  public func add(reactables: [Reactable]) {
    if (reactables.count > 0) {
      currentIndex = viewModels.count
      let newViewModels = reactables.map{ReactableViewModel(with: $0)}
      viewModels += newViewModels
      delegate.updatingData(with: newViewModels)
      delegate.display(at: currentIndex)
    }
  }
}

protocol TheaterDelegate: class {
  func display(at index: Int)
  
  func updatingData(with newViewModels: [ReactableViewModel])
}
