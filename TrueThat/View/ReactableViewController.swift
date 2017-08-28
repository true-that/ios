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
  var mediaViewController: ReactableMediaViewController!
  
  @IBOutlet weak var directorLabel: UILabel!
  @IBOutlet weak var timeAgoLabel: UILabel!
  @IBOutlet weak var reactionEmojiLabel: UILabel!
  @IBOutlet weak var reactionsCountLabel: UILabel!

  // MARK: Initialization
  static func instantiate(with reactable: Reactable) -> ReactableViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "ReactableScene")
      as! ReactableViewController
    viewController.viewModel = ReactableViewModel(with: reactable)
    viewController.viewModel.delegate = viewController
    return viewController
  }
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard viewModel != nil else {
      return
    }
    
    // Performs data binding
    directorLabel.reactive.text <~ viewModel.directorName
    timeAgoLabel.reactive.text <~ viewModel.timeAgo
    reactionEmojiLabel.reactive.text <~ viewModel.reactionEmoji
    reactionsCountLabel.reactive.text <~ viewModel.reactionsCount
    
    // Loads media view controller
    mediaViewController = ReactableMediaViewController.instantiate(with: viewModel.model)
    
    guard mediaViewController != nil else {
      // Reactable does not have a media and so had been displayed.
      viewModel.didDisplay()
      return
    }
    
    self.addChildViewController(mediaViewController)
    self.view.addSubview(mediaViewController.view)
    mediaViewController.view.frame = self.view.bounds
    mediaViewController.view.autoresizingMask = UIViewAutoresizing.flexibleWidth
    mediaViewController.view.translatesAutoresizingMaskIntoConstraints = true
    mediaViewController.delegate = self
    // Send media to back
    self.view.sendSubview(toBack: mediaViewController.view)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.didDisappear()
  }
}

// MARK: PoseMediaViewControllerDelegate
extension ReactableViewController: ReactableMediaViewControllerDelegate {
  func didDownloadMedia() {
    viewModel.didDisplay()
  }
}

protocol ReactableMediaViewControllerDelegate {
  
  /// Invoked once the short video had been successfully downloaded.
  func didDownloadMedia()
}
