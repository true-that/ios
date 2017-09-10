//
//  ScenesPageViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 09/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Crashlytics
import UIKit
import ReactiveSwift
import ReactiveCocoa

class ScenesPageViewController: UIPageViewController {
  // MARK: Properties
  weak var viewModel: ScenesPageViewModel!
  weak var pagerDelegate: ScenesPageViewControllerDelegate?
  /// View controllers that are displayed in this page, ordered by order of appearance.
  var orderedViewControllers = [SceneViewController]()
  
  // MARK: Initializers
  static func instantiate() -> ScenesPageViewController {
    let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
      .instantiateViewController(withIdentifier: "ScenesPageScene")
      as! ScenesPageViewController
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
  fileprivate func notifyScenesPageDelegateOfNewIndex() {
    if currentViewController != nil,
       let currentIndex = orderedViewControllers.index(of: currentViewController!) {
      pagerDelegate?.ScenesPageViewController(self, didUpdatePageIndex: currentIndex)
      viewModel.currentIndex = currentIndex
    }
  }
  
  /// Currently displayed scene.
  public var currentViewController: SceneViewController? {
    if let currentViewController = viewControllers?.first {
      return (currentViewController as? SceneViewController)!
    }
    return nil
  }
}

// MARK: UIPageViewControllerDataSource
extension ScenesPageViewController: UIPageViewControllerDataSource {
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
extension ScenesPageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController,
                          didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController],
                          transitionCompleted completed: Bool) {
    notifyScenesPageDelegateOfNewIndex()
  }
}

// MARK: ScenesPageDelegate
extension ScenesPageViewController: ScenesPageDelegate {
  func display(at index: Int) {
    if index >= 0 && index < orderedViewControllers.count {
      App.log.debug("Displaying the \(index)-th scene.")
      Crashlytics.sharedInstance().setObjectValue(
        viewModel.scenes[index].toDictionary(),
        forKey: LoggingKey.displayedScene.rawValue.snakeCased()!.uppercased())
      setViewControllers([orderedViewControllers[index]],
                         direction: index >= viewModel.currentIndex ? .forward : .reverse,
                         animated: true,
                         completion: { (finished) -> Void in
                          // Setting the view controller programmatically does not fire
                          // any delegate methods, so we have to manually notify the
                          // 'pagerDelegate' of the new index.
                          self.notifyScenesPageDelegateOfNewIndex()
      })
    } else {
      App.log.error("Trying to display \(index)-th scene while only hanving \(orderedViewControllers.count).")
    }
  }
  
  func scroll(to index: Int) {
    if currentViewController != nil {
      App.log.debug("Scrolling to \(index)-th scene.")
      display(at: index)
    }
  }

  
  /// Updates the view controllers of this pager.
  ///
  /// - Parameter newViewModels: to create view controllers from
  func updatingData(with newScenes: [Scene]) {
    App.log.debug("\(newScenes.count) new scenes.")
    self.orderedViewControllers +=
      newScenes.map{SceneViewController.instantiate(with: $0)}
    self.pagerDelegate?.ScenesPageViewController(
      self, didUpdatePageCount: self.orderedViewControllers.count)
  }
}

protocol ScenesPageViewControllerDelegate: class {

  /**
   Called when the number of pages is updated.

   - parameter ScenesPageViewController: the ScenesPageViewController instance
   - parameter count: the total number of pages.
   */
  func ScenesPageViewController(_ ScenesPageViewController: ScenesPageViewController,
                                 didUpdatePageCount count: Int)

  /**
   Called when the current index is updated.

   - parameter ScenesPageViewController: the ScenesPageViewController instance
   - parameter index: the index of the currently visible page.
   */
  func ScenesPageViewController(_ ScenesPageViewController: ScenesPageViewController,
                                 didUpdatePageIndex index: Int)

}
