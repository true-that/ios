//
//  ReactablesPageWrapperViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 24/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class ReactablesPageWrapperViewController: UIViewController {
  // MARK: Propertoes
  var viewModel: ReactablesPageViewModel!
  var reactablesPage: ReactablesPageViewController!
  var doDetection = false
  @IBOutlet weak var nonFoundStackView: UIStackView!
  @IBOutlet weak var nonFoundLabel: UILabel!
  @IBOutlet weak var nonFoundImageView: UIImageView!
  @IBOutlet weak var loadingImage: UIImageView!
  /// View controllers that are displayed in this page, ordered by order of appearance.
  var orderedViewControllers = [ReactableViewController]()
  
  // MARK: Initializers
  static func instantiate(doDetection: Bool) -> ReactablesPageWrapperViewController {
    let viewController = UIStoryboard(name: "Main", bundle: Bundle.main)
      .instantiateViewController(withIdentifier: "ReactablesPageWrapperScene")
      as! ReactablesPageWrapperViewController
    viewController.doDetection = doDetection
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    App.log.verbose("viewDidLoad")
    
    // Loads reactables container
    reactablesPage = ReactablesPageViewController.instantiate()
    self.addChildViewController(reactablesPage)
    self.view.addSubview(reactablesPage.view)
    
    if (viewModel == nil) {
      viewModel = ReactablesPageViewModel()
      viewModel.delegate = reactablesPage
      reactablesPage.viewModel = viewModel
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    App.log.verbose("viewDidAppear")
    App.detecionModule.start()
    if App.authModule.isAuthOk {
      fetchIfEmpty()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    App.log.verbose("viewWillDisappear")
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
}
