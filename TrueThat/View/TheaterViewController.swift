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
  }
}

// MARK: FetchScenesDelegate
extension TheaterViewController: FetchScenesDelegate {
  @discardableResult func fetchingProducer() -> SignalProducer<[Scene], NSError> {
    return TheaterApi.fetchScenes(for: App.authModule.current!)
  }
}
