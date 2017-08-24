//
//  TheaterViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SwiftyBeaver

class TheaterViewController: BaseViewController {

  var reactablesPageWrapper: ReactablesPageWrapperViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Loads reactables container
    reactablesPageWrapper = ReactablesPageWrapperViewController.instantiate(doDetection: true)
    self.addChildViewController(reactablesPageWrapper)
    self.view.addSubview(reactablesPageWrapper.view)
    reactablesPageWrapper.viewModel.fetchingDelegate = self
    
    // Navigation swipe gesture
    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.navigateToStudio))
    swipeUp.direction = .up
    self.view.addGestureRecognizer(swipeUp)
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
extension TheaterViewController: FetchReactablesDelegate {
  @discardableResult func fetchingProducer() -> SignalProducer<[Reactable], NSError> {
    return TheaterApi.fetchReactables(for: App.authModule.current!)
  }
}
