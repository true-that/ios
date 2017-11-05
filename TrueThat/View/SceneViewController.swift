//
// Created by Ohad Navon on 12/07/2017.
// Copyright (c) 2017 TrueThat. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class SceneViewController: NestedViewController {
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

    guard viewModel != nil && viewModel.scene.id != nil else {
      return
    }
    logTag += " \(viewModel.scene.id!)"

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
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.didDisappear()
  }

  override func viewDidShow() {
    super.viewDidShow()
    viewModel.didAppear()
  }

  override func viewDidHide() {
    super.viewDidShow()
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

  func show(alert: String, title: String, okAction: String) {
    let alertController = UIAlertController(title: title, message: alert,
                                            preferredStyle: .alert)
    let okAction = UIAlertAction(title: okAction, style: .default, handler: nil)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }

  func display(media: Media) {
    hideMedia()

    mediaViewController = MediaViewController.instantiate(with: media)
    mediaViewController.delegate = viewModel

    guard mediaViewController != nil else {
      return
    }

    self.addChildViewController(mediaViewController)
    self.view.addSubview(mediaViewController.view)
    mediaViewController.view.frame = self.view.bounds
    mediaViewController.view.autoresizingMask = UIViewAutoresizing.flexibleWidth
    mediaViewController.view.translatesAutoresizingMaskIntoConstraints = true
    // Send media to back
    self.view.sendSubview(toBack: mediaViewController.view)
    mediaViewController.isVisible = true
  }

  func mediaFinished() -> Bool {
    if mediaViewController == nil {
      return false
    }
    return mediaViewController!.finished
  }

  func hideMedia() {
    if mediaViewController != nil {
      UIHelper.remove(viewController: mediaViewController!)
      mediaViewController = nil
    }
  }
}
