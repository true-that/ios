//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class ReactableViewController: UIViewController {
  // MARK: Properties
  public var viewModel: ReactableViewModel!

  @IBOutlet weak var directorLabel: UILabel!
  @IBOutlet weak var timeAgoLabel: UILabel!
  @IBOutlet weak var reactionEmojiLabel: UILabel!
  @IBOutlet weak var reactionsCountLabel: UILabel!

  // MARK: Initialization
  static func instantiate(with reactable: Reactable) -> ReactableViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "ReactableScene")
      as! ReactableViewController
    viewController.viewModel = ReactableViewModel.instantiate(with: reactable)
    viewController.viewModel.delegate = viewController
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let viewModel = viewModel else {
      return
    }
    
    // Performs data binding
    directorLabel.reactive.text <~ viewModel.directorName
    timeAgoLabel.reactive.text <~ viewModel.timeAgo
    reactionEmojiLabel.reactive.text <~ viewModel.reactionEmoji
    reactionsCountLabel.reactive.text <~ viewModel.reactionsCount
    
    // Loads view model
    viewModel.didLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // Trigger didDisplay if not waiting for additional content
    if type(of: viewModel.model) == Reactable.self {
      viewModel.didDisplay()
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.didDisappear()
  }
}

// MARK: PoseMediaDelegate
extension ReactableViewController: PoseMediaDelegate {
  func loadPoseImage() {
    let mediaViewController = PoseMediaViewController.instantiate(with: viewModel.model as! Pose)
    self.addChildViewController(mediaViewController)
    self.view.addSubview(mediaViewController.view)
    mediaViewController.view.frame = self.view.bounds
    mediaViewController.view.autoresizingMask = UIViewAutoresizing.flexibleWidth
    mediaViewController.view.translatesAutoresizingMaskIntoConstraints = true
    mediaViewController.delegate = self
    // Send media to back
    self.view.sendSubview(toBack: mediaViewController.view)
  }
}

// MARK: PoseMediaViewControllerDelegate
extension ReactableViewController: PoseMediaViewControllerDelegate {
  func didDownloadMedia() {
    viewModel.didDisplay()
  }
}
