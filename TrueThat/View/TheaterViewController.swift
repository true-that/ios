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
  var reactablesPage: ReactablesPageViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Loads reactables container
    reactablesPage = ReactablesPageViewController.instantiate(doDetection: true)
    reactablesPage.fetchingDelegate = self
    self.addChildViewController(reactablesPage)
    self.view.addSubview(reactablesPage.view)
    
    // Navigation swipe gesture
    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.navigateToStudio))
    swipeUp.direction = .up
    self.view.addGestureRecognizer(swipeUp)
  }
  
  override func didAuthOk() {
    super.didAuthOk()
    reactablesPage.didAuthOk()
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
