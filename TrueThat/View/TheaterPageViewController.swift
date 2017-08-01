//
//  TheaterPageViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 09/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SwiftyBeaver

class TheaterPageViewController: UIPageViewController {
  var viewModel: TheaterViewModel!
  var log = SwiftyBeaver.self
  weak var pagerDelegate: TheaterPageViewControllerDelegate?

  var orderedViewControllers = [ReactableViewController]()

  override func viewDidLoad() {
    log.verbose("viewDidLoad")
    super.viewDidLoad()

    dataSource = self
    delegate = self
    
    if (viewModel == nil) {
      viewModel = TheaterViewModel()
      viewModel.delegate = self
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    log.verbose("viewDidAppear")
    super.viewDidAppear(animated)
    viewModel.didAppear()
  }
  
  public func inject(log: SwiftyBeaver.Type) {
    self.log = log
  }

  /**
   Notifies the delegate that the current page index was updated.
   */
  fileprivate func notifyTheaterDelegateOfNewIndex() {
    if currentViewController != nil,
       let currentIndex = orderedViewControllers.index(of: currentViewController!) {
      pagerDelegate?.theaterPageViewController(self, didUpdatePageIndex: currentIndex)
      viewModel.currentIndex = currentIndex
    }
  }
  
  public var currentViewController: ReactableViewController? {
    if let currentViewController = viewControllers?.first {
      return (currentViewController as? ReactableViewController)!
    }
    return nil
  }
}

// MARK: UIPageViewControllerDataSource

extension TheaterPageViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let previousIndex = viewModel.navigatePrevious() else {
      return nil
    }

    return orderedViewControllers[previousIndex]
  }

  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let nextIndex = viewModel.navigateNext() else {
      return nil
    }
    
    return orderedViewControllers[nextIndex]  }
}

// MARK: UIPageViewControllerDelegate

extension TheaterPageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController,
                          didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController],
                          transitionCompleted completed: Bool) {
    notifyTheaterDelegateOfNewIndex()
  }
}

// MARK: TheaterDelegate

extension TheaterPageViewController: TheaterDelegate {
  func display(at index: Int) {
    if index >= 0 && index < orderedViewControllers.count {
      log.verbose("Displaying the \(index)-th reactable.")
      setViewControllers([orderedViewControllers[index]],
                         direction: index >= viewModel.currentIndex ? .forward : .reverse,
                         animated: true,
                         completion: { (finished) -> Void in
                          // Setting the view controller programmatically does not fire
                          // any delegate methods, so we have to manually notify the
                          // 'pagerDelegate' of the new index.
                          self.notifyTheaterDelegateOfNewIndex()
      })
    } else {
      log.error("Trying to display \(index)-th reactable while only hanving \(orderedViewControllers.count).")
    }
  }
  
  func scroll(to index: Int) {
    if currentViewController != nil {
      log.verbose("Scrolling to \(index)-th reactable.")
      display(at: index)
    }
  }

  
  /// Updates the view controllers of this pager.
  ///
  /// - Parameter newViewModels: to create view controllers from
  func updatingData(with newReactables: [Reactable]) {
    log.verbose("\(newReactables.count) new reactables.")
    self.orderedViewControllers +=
      newReactables.map{ReactableViewController.instantiate(with: $0)}
    self.pagerDelegate?.theaterPageViewController(
      self, didUpdatePageCount: self.orderedViewControllers.count)
  }
}

protocol TheaterPageViewControllerDelegate: class {

  /**
   Called when the number of pages is updated.

   - parameter theaterPageViewController: the TheaterPageViewController instance
   - parameter count: the total number of pages.
   */
  func theaterPageViewController(_ theaterPageViewController: TheaterPageViewController,
                                 didUpdatePageCount count: Int)

  /**
   Called when the current index is updated.

   - parameter theaterPageViewController: the TheaterPageViewController instance
   - parameter index: the index of the currently visible page.
   */
  func theaterPageViewController(_ theaterPageViewController: TheaterPageViewController,
                                 didUpdatePageIndex index: Int)

}
