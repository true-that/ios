//
//  RepertoireViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SwiftyBeaver

class RepertoireViewController: BaseViewController {
  // MARK: Properties
  var scenesPageWrapper: ScenesPageWrapperViewController!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Loads scenes container
    scenesPageWrapper = ScenesPageWrapperViewController.instantiate(doDetection: true)
    self.addChildViewController(scenesPageWrapper)
    self.view.addSubview(scenesPageWrapper.view)
    scenesPageWrapper.viewModel.fetchingDelegate = self
    
    // Navigation swipe gesture
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.navigateToStudio))
    swipeDown.direction = .down
    self.view.addGestureRecognizer(swipeDown)
  }
  
  override func didAuthOk() {
    super.didAuthOk()
    scenesPageWrapper.didAuthOk()
  }
  
  // MARK: View Controller Navigation
  @objc private func navigateToStudio() {
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "StudioScene"),
      animated: true, completion: nil)
  }
}

// MARK: FetchScenesDelegate
extension RepertoireViewController: FetchScenesDelegate {
  @discardableResult func fetchingProducer() -> SignalProducer<[Scene], NSError> {
    return RepertoireApi.fetchScenes(for: App.authModule.current!)
  }
}
