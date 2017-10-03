//
//  ScenesPageWrapperViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 24/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class ScenesPageWrapperViewController: UIViewController {
  // MARK: Propertoes
  var viewModel: ScenesPageViewModel!
  var scenesPage: ScenesPageViewController!
  var doDetection = false
  @IBOutlet weak var nonFoundStackView: UIStackView!
  @IBOutlet weak var nonFoundLabel: UILabel!
  @IBOutlet weak var nonFoundImageView: UIImageView!
  @IBOutlet weak var loadingImage: UIImageView!
  /// View controllers that are displayed in this page, ordered by order of appearance.
  var orderedViewControllers = [SceneViewController]()

  // MARK: Initializers
  static func instantiate(doDetection: Bool) -> ScenesPageWrapperViewController {
    let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
      .instantiateViewController(withIdentifier: "ScenesPageWrapperScene")
      as! ScenesPageWrapperViewController
    viewController.doDetection = doDetection
    return viewController
  }

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    App.log.debug("viewDidLoad")

    // Loads scenes container
    scenesPage = ScenesPageViewController.instantiate()
    self.addChildViewController(scenesPage)
    self.view.addSubview(scenesPage.view)

    if viewModel == nil {
      viewModel = ScenesPageViewModel()
      viewModel.delegate = scenesPage
      scenesPage.viewModel = viewModel
    }
    // Sets up visibility
    nonFoundStackView.reactive.isHidden <~ viewModel.nonFoundHidden
    loadingImage.reactive.isHidden <~ viewModel.loadingImageHidden
    // Style
    nonFoundImageView.image = UIImage(named: "teddy.png")
    nonFoundLabel.textColor = Color.theme.value
    // Sets up loading image
    UIHelper.initLoadingImage(loadingImage)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    App.log.debug("viewWillAppear")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    App.log.debug("viewDidAppear")
    App.detecionModule.start()
    if App.authModule.isAuthOk {
      fetchIfEmpty()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    App.log.debug("viewWillDisappear")
    App.detecionModule.stop()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    App.log.debug("viewDidDisappear")
  }

  func didAuthOk() {
    fetchIfEmpty()
  }

  func fetchIfEmpty() {
    if viewModel.scenes.count == 0 {
      viewModel.fetchingData()
    }
  }
}
