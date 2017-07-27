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

class TheaterPageViewController: UIPageViewController {
  var viewModel: TheaterViewModel!
  weak var pagerDelegate: TheaterPageViewControllerDelegate?

  var orderedViewControllers = [ReactableViewController]()

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = self
    delegate = self
    
    if (viewModel == nil) {
      viewModel = TheaterViewModel()
      viewModel.delegate = self
    }
    
//    viewModel.reactableViewModels.producer.startWithValues{ reactableViewModels in
//      log.debug("\(reactableViewModels.count) new reactables")
//      let displayInitial = self.orderedViewControllers.count == 0
//      self.orderedViewControllers +=
//        reactableViewModels.map{ReactableViewController.instantiate(with: $0)}
//      self.pagerDelegate?.theaterPageViewController(
//        self, didUpdatePageCount: self.orderedViewControllers.count)
//      if let initialViewController = self.orderedViewControllers.first, displayInitial {
//        self.scrollToViewController(initialViewController)
//      }
//    }

    viewModel.fetchingData()
//    if (orderedViewControllers.count == 0) {
//      viewModel.fetchingData()
//      let newVC = ReactableViewController.instantiate(with: viewModel.reactables[0])
//      orderedViewControllers += [newVC, ReactableViewController.instantiate(with: viewModel.reactables[1])]
//    }
//    
//    if let initialViewController = orderedViewControllers.first {
//      scrollToViewController(initialViewController)
//    }
//    
//    pagerDelegate?.theaterPageViewController(
//      self, didUpdatePageCount: orderedViewControllers.count)
  }
  
  /**
   Scrolls to the given 'viewController' page.

   - parameter viewController: the view controller to show.
   - parameter direction: to which to scroll (useful for animated scrolling).
   */
  fileprivate func scrollToViewController(_ viewController: UIViewController,
                                      direction: UIPageViewControllerNavigationDirection = .forward) {
    setViewControllers([viewController],
                       direction: direction,
                       animated: true,
                       completion: { (finished) -> Void in
//                          Setting the view controller programmatically does not fire
//                          any delegate methods, so we have to manually notify the
//                          'tutorialDelegate' of the new index.
                         self.notifyTheaterDelegateOfNewIndex()
                       })
  }

  /**
   Notifies the delegate that the current page index was updated.
   */
  fileprivate func notifyTheaterDelegateOfNewIndex() {
    if let firstViewController = viewControllers?.first,
       let index = orderedViewControllers.index(of: firstViewController as! ReactableViewController) {
      pagerDelegate?.theaterPageViewController(self, didUpdatePageIndex: index)
      log.debug("new index \(index)")
    }
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
  /**
   Scrolls to the view controller at the given index. Automatically calculates
   the direction.
   
   - parameter index: the new index to scroll to
   */
  func display(at index: Int) {
    log.debug("displaying at \(index)")
    if let firstViewController = viewControllers?.first,
      let currentIndex = orderedViewControllers.index(of: firstViewController as! ReactableViewController) {
      let direction: UIPageViewControllerNavigationDirection = index >= currentIndex ? .forward : .reverse
      let nextViewController = orderedViewControllers[index]
      scrollToViewController(nextViewController, direction: direction)
    }
  }

  
  /// Updates the view controllers of this pager.
  ///
  /// - Parameter newViewModels: to create view controllers from
  func updatingData(with newViewModels: [ReactableViewModel]) {
    log.debug("\(newViewModels.count) new reactables")
    self.orderedViewControllers +=
      newViewModels.map{ReactableViewController.instantiate(with: $0)}
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
