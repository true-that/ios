//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class SceneViewController: UIViewController {
  // MARK: Properties
  public var viewModel: SceneViewModel!
  var mediaViewController: MediaViewController!

  @IBOutlet weak var directorLabel: UILabel!
  @IBOutlet weak var timeAgoLabel: UILabel!
  @IBOutlet weak var reactionEmojiLabel: UILabel!
  @IBOutlet weak var reactionsCountLabel: UILabel!
  @IBOutlet weak var loadingImage: UIImageView!
  @IBOutlet weak var optionsButton: UIImageView!
  @IBOutlet weak var reportLabel: UILabel!

  // MARK: Initialization
  static func instantiate(with scene: Scene) -> SceneViewController {
    let viewController = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "SceneScene")
      as! SceneViewController
    viewController.viewModel = SceneViewModel(with: scene)
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
    loadingImage.reactive.isHidden <~ viewModel.loadingImageHidden
    optionsButton.reactive.isHidden <~ viewModel.optionsButtonHidden
    reportLabel.reactive.isHidden <~ viewModel.reportHidden

    // Sets up loading image
    UIHelper.initLoadingImage(loadingImage)

    // Initialize options UI
    optionsButton.image = UIImage(named: "options.png")
    optionsButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.showOptions)))
    optionsButton.isUserInteractionEnabled = true
    reportLabel.textColor = Color.error.value
    reportLabel.layer.backgroundColor = Color.lightText.value.cgColor
    reportLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.didReport)))
    reportLabel.isUserInteractionEnabled = true
    reportLabel.layer.cornerRadius = 5

    // Loads media view controller
    mediaViewController = MediaViewController.instantiate(with: viewModel.model.rootMedia)

    guard mediaViewController != nil else {
      // Scene does not have a media and so had been displayed.
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

  // MARK: Actions
  /// Exposes the options menu
  @objc private func showOptions() {
    viewModel.reportHidden.value = false
  }

  /// Reports the scene for offensive content.
  @objc private func didReport() {
    viewModel.didReport()
  }
}

// MARK: MediaViewControllerDelegate
extension SceneViewController: MediaViewControllerDelegate {
  func didDownloadMedia() {
    viewModel.didDisplay()
  }

  func showLoader() {
    viewModel.loadingImageHidden.value = false
  }

  func hideLoader() {
    viewModel.loadingImageHidden.value = true
  }
}

// MARK: SceneViewDelegate
extension SceneViewController: SceneViewDelegate {
  func animateReactionImage() {
    UIView.animate(withDuration: 0.3, animations: {
      self.reactionEmojiLabel.transform = CGAffineTransform.identity.scaledBy(x: 1.6, y: 1.6)
    }, completion: { _ in
      UIView.animate(withDuration: 0.3, animations: {
        self.reactionEmojiLabel.transform = CGAffineTransform.identity
      })
    })
  }

  func show(alert: String, withTitle: String, okAction: String) {
    let alertController = UIAlertController(title: withTitle, message: alert,
                                            preferredStyle: .alert)
    let okAction = UIAlertAction(title: okAction, style: .default, handler: nil)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
