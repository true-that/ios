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
  var reactablesPageWrapper: ReactablesPageWrapperViewController!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Loads reactables container
    reactablesPageWrapper = ReactablesPageWrapperViewController.instantiate(doDetection: true)
    self.addChildViewController(reactablesPageWrapper)
    self.view.addSubview(reactablesPageWrapper.view)
    reactablesPageWrapper.viewModel.fetchingDelegate = self
    
    // Navigation swipe gesture
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.navigateToStudio))
    swipeDown.direction = .down
    self.view.addGestureRecognizer(swipeDown)
  }
  
  override func didAuthOk() {
    super.didAuthOk()
    reactablesPageWrapper.didAuthOk()
  }
  
  // MARK: View Controller Navigation
  @objc private func navigateToStudio() {
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "StudioScene"),
      animated: true, completion: nil)
  }
}

// MARK: FetchReactablesDelegate
extension RepertoireViewController: FetchReactablesDelegate {
  @discardableResult func fetchingProducer() -> SignalProducer<[Reactable], NSError> {
    return RepertoireApi.fetchReactables(for: App.authModule.current!)
  }
}
