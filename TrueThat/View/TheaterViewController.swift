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
  }
  
  override func didAuthOk() {
    super.didAuthOk()
    reactablesPage.didAuthOk()
  }
}

// MARK: FetchReactablesDelegate
extension TheaterViewController: FetchReactablesDelegate {
  @discardableResult func fetchingProducer() -> SignalProducer<[Reactable], NSError> {
    return TheaterApi.fetchReactables(for: App.authModule.current!)
  }
}