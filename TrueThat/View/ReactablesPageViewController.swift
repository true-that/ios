//
//  ReactablesPageViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 09/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Crashlytics
import UIKit
import ReactiveSwift
import ReactiveCocoa

class ReactablesPageViewController: UIPageViewController {
  // MARK: Properties
  weak var viewModel: ReactablesPageViewModel!
  weak var pagerDelegate: ReactablesPageViewControllerDelegate?
  /// View controllers that are displayed in this page, ordered by order of appearance.
  var orderedViewControllers = [ReactableViewController]()
  
  // MARK: Initializers
  static func instantiate() -> ReactablesPageViewController {
    let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
      .instantiateViewController(withIdentifier: "ReactablesPageScene")
      as! ReactablesPageViewController
    return viewController
  }

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    App.log.debug("viewDidLoad")
    
    dataSource = self
    delegate = self
  }

  /// Notifies the delegate that the current page index was updated.
  fileprivate func notifyReactablesPageDelegateOfNewIndex() {
    if currentViewController != nil,
       let currentIndex = orderedViewControllers.index(of: currentViewController!) {
      pagerDelegate?.ReactablesPageViewController(self, didUpdatePageIndex: currentIndex)
      viewModel.currentIndex = currentIndex
    }
  }
  
  /// Currently displayed reactable.
  public var currentViewController: ReactableViewController? {
    if let currentViewController = viewControllers?.first {
      return (currentViewController as? ReactableViewController)!
    }
    return nil
  }
}

// MARK: UIPageViewControllerDataSource
extension ReactablesPageViewController: UIPageViewControllerDataSource {
  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController) -> UIViewController? {
    // If we are at the first view, then return.
    guard let previousIndex = viewModel.navigatePrevious() else {
      return nil
    }

    return orderedViewControllers[previousIndex]
  }

  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController) -> UIViewController? {
    // If there are no more views to display, then return.
    guard let nextIndex = viewModel.navigateNext() else {
      return nil
    }
    
    return orderedViewControllers[nextIndex]  }
}

// MARK: UIPageViewControllerDelegate
extension ReactablesPageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController,
                          didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController],
                          transitionCompleted completed: Bool) {
    notifyReactablesPageDelegateOfNewIndex()
  }
}

// MARK: ReactablesPageDelegate
extension ReactablesPageViewController: ReactablesPageDelegate {
  func display(at index: Int) {
    if index >= 0 && index < orderedViewControllers.count {
      App.log.debug("Displaying the \(index)-th reactable.")
      Crashlytics.sharedInstance().setObjectValue(
        viewModel.reactables[index].toDictionary(),
        forKey: LoggingKey.displayedReactable.rawValue)
      setViewControllers([orderedViewControllers[index]],
                         direction: index >= viewModel.currentIndex ? .forward : .reverse,
                         animated: true,
                         completion: { (finished) -> Void in
                          // Setting the view controller programmatically does not fire
                          // any delegate methods, so we have to manually notify the
                          // 'pagerDelegate' of the new index.
                          self.notifyReactablesPageDelegateOfNewIndex()
      })
    } else {
      App.log.error("Trying to display \(index)-th reactable while only hanving \(orderedViewControllers.count).")
    }
  }
  
  func scroll(to index: Int) {
    if currentViewController != nil {
      App.log.debug("Scrolling to \(index)-th reactable.")
      display(at: index)
    }
  }

  
  /// Updates the view controllers of this pager.
  ///
  /// - Parameter newViewModels: to create view controllers from
  func updatingData(with newReactables: [Reactable]) {
    App.log.debug("\(newReactables.count) new reactables.")
    self.orderedViewControllers +=
      newReactables.map{ReactableViewController.instantiate(with: $0)}
    self.pagerDelegate?.ReactablesPageViewController(
      self, didUpdatePageCount: self.orderedViewControllers.count)
  }
}

protocol ReactablesPageViewControllerDelegate: class {

  /**
   Called when the number of pages is updated.

   - parameter ReactablesPageViewController: the ReactablesPageViewController instance
   - parameter count: the total number of pages.
   */
  func ReactablesPageViewController(_ ReactablesPageViewController: ReactablesPageViewController,
                                 didUpdatePageCount count: Int)

  /**
   Called when the current index is updated.

   - parameter ReactablesPageViewController: the ReactablesPageViewController instance
   - parameter index: the index of the currently visible page.
   */
  func ReactablesPageViewController(_ ReactablesPageViewController: ReactablesPageViewController,
                                 didUpdatePageIndex index: Int)

}
