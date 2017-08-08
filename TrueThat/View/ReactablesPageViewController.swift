//
//  ReactablesPageViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 09/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class ReactablesPageViewController: UIPageViewController {
  var viewModel: ReactablesPageViewModel!
  var doDetection = false
  weak var pagerDelegate: ReactablesPageViewControllerDelegate?
  var fetchingDelegate: FetchReactablesDelegate!

  /// View controllers that are displayed in this page, ordered by order of appearance.
  var orderedViewControllers = [ReactableViewController]()
  
  static func instantiate(doDetection: Bool) -> ReactablesPageViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "ReactablesPageScene")
      as! ReactablesPageViewController
    viewController.doDetection = doDetection
    return viewController
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = self
    delegate = self
    
    if (viewModel == nil) {
      viewModel = ReactablesPageViewModel()
      viewModel.delegate = self
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    App.detecionModule.start()
    if App.authModule.isAuthOk {
      fetchIfEmpty()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    App.detecionModule.stop()
  }
  
  func didAuthOk() {
    if presentingViewController != nil {
      fetchIfEmpty()
    }
  }
  
  func fetchIfEmpty() {
    if viewModel.reactables.count == 0 {
      viewModel.fetchingData()
    }
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
      App.log.verbose("Displaying the \(index)-th reactable.")
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
      App.log.verbose("Scrolling to \(index)-th reactable.")
      display(at: index)
    }
  }

  
  /// Updates the view controllers of this pager.
  ///
  /// - Parameter newViewModels: to create view controllers from
  func updatingData(with newReactables: [Reactable]) {
    App.log.verbose("\(newReactables.count) new reactables.")
    self.orderedViewControllers +=
      newReactables.map{ReactableViewController.instantiate(with: $0)}
    self.pagerDelegate?.ReactablesPageViewController(
      self, didUpdatePageCount: self.orderedViewControllers.count)
  }
  
  @discardableResult func fetchingProducer() -> SignalProducer<[Reactable], NSError> {
    return fetchingDelegate.fetchingProducer()
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

protocol FetchReactablesDelegate {
  /// - Returns: a signal producer to fetch reactables from our backend.
  @discardableResult func fetchingProducer() -> SignalProducer<[Reactable], NSError>
}
