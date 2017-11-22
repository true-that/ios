//
//  StudioViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import AVFoundation
import UIKit
import ReactiveSwift
import ReactiveCocoa
import SwiftyBeaver

class StudioViewController: BaseViewController {
  // MARK: Peroperties
  var viewModel: StudioViewModel!
  var swiftyCam: SwiftyCamViewController!
  var scenePreview: UIViewController!
  var mediaViewController: MediaViewController?
  var player : AVAudioPlayer?

  @IBOutlet weak var captureButton: SwiftyCamButton!
  @IBOutlet weak var switchCameraButton: UIImageView!
  @IBOutlet weak var sendButton: UIImageView!
  @IBOutlet weak var loadingImage: UIImageView!
  @IBOutlet weak var cancelButton: UILabel!

  @IBOutlet weak var reactionLabel: UILabel!

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize view model
    if viewModel == nil {
      viewModel = StudioViewModel()
      viewModel.delegate = self
    }

    App.detecionModule.delegate = self

    initUI()
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      // Dont initialize camera on Simulator
      self.view.backgroundColor = Color.shadow.value
      // Button delegate shaould be defined externally
    #else
//      initSwiftyCam()
    #endif
  }

  func initSwiftyCam() {
    swiftyCam = SwiftyCamViewController()
    swiftyCam.defaultCamera = .front
    // Camera preview
    self.addChildViewController(swiftyCam)
    self.view.addSubview(swiftyCam.view)
    swiftyCam.view.reactive.isHidden <~ viewModel.cameraSessionHidden
    // Send preview to back
    self.view.sendSubview(toBack: swiftyCam.view)
    swiftyCam.cameraDelegate = self
    // Capture button
    captureButton.delegate = swiftyCam
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.didAppear()
  }

  // MARK: Initialization
  private func initUI() {
    reactionLabel.isHidden = true
    // Enable for interaction
    captureButton.isUserInteractionEnabled = true
    cancelButton.isUserInteractionEnabled = true
    switchCameraButton.isUserInteractionEnabled = true
    sendButton.isUserInteractionEnabled = true

    // Initialize tap gestures
    cancelButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.didCancel)))
    switchCameraButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.switchCamera)))
    sendButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.willSend)))

    // Initialize images
    viewModel.captureButtonImageName.producer.on { imageName in
      DispatchQueue.main.async {
        self.captureButton.setBackgroundImage(UIImage(named: imageName), for: UIControlState.normal)
      }
    }.start()
    captureButton.layer.backgroundColor = Color.shadow.withAlpha(0.0).cgColor

    switchCameraButton.image = UIImage(named: "switch_camera.png")
    sendButton.image = UIImage(named: "send.png")

    // Initialize visibility hooks
    captureButton.reactive.isHidden <~ viewModel.captureButtonHidden
    switchCameraButton.reactive.isHidden <~ viewModel.switchCameraButtonHidden
    cancelButton.reactive.isHidden <~ viewModel.cancelButtonHidden
    sendButton.reactive.isHidden <~ viewModel.sendButtonHidden
    loadingImage.reactive.isHidden <~ viewModel.loadingImageHidden

    // Sets up loading image
    UIHelper.initLoadingImage(loadingImage)

    // Initializes Scene preview
    if scenePreview != nil {
      UIHelper.remove(viewController: scenePreview)
    }
    scenePreview = UIViewController()
    scenePreview.view.reactive.isHidden <~ viewModel.scenePreviewHidden
    addChildViewController(scenePreview)
    view.addSubview(scenePreview.view)
    view.sendSubview(toBack: scenePreview.view)
//    // Create reaction buttons
//    let reactionButtons: [UIButton] = Emotion.values.map { emotion in
//      let button = UIButton()
//      button.accessibilityLabel = "\(emotion.description) reaction"
//      button.setTitle(emotion.emoji, for: .normal)
//      button.titleLabel!.font = button.titleLabel!.font.withSize(20)
//      button.addTarget(self, action: #selector(self.didChose(_:)), for: .touchUpInside)
//      return button
//    }
//    // Create previous media button
//    let previousButton = UIButton()
//    previousButton.reactive.isHidden <~ viewModel.previousMediaHidden
//    previousButton.setTitle("⏎", for: .normal)
//    previousButton.accessibilityLabel = "previous media"
//    previousButton.addTarget(self, action: #selector(self.displayingParentMedia), for: .touchUpInside)
//    previousButton.layer.shadowColor = Color.shadow.value.cgColor
//    previousButton.layer.shadowOpacity = 0.4
//    previousButton.layer.shadowOffset = CGSize.zero
//    previousButton.layer.shadowRadius = 4
//    // Add all of them to a stack view
//    let reactionsStackview = UIStackView(arrangedSubviews: reactionButtons + [previousButton])
//    reactionsStackview.axis = .vertical
//    reactionsStackview.spacing = 16
//    reactionsStackview.alignment = .fill
//    reactionsStackview.distribution = .fillEqually
//    // Center it vertically close to the view leading border.
//    reactionsStackview.translatesAutoresizingMaskIntoConstraints = false
//    scenePreview.view.addSubview(reactionsStackview)
//    scenePreview.view.bringSubview(toFront: reactionsStackview)
//    scenePreview.view.addConstraints([
//      NSLayoutConstraint(item: reactionsStackview, attribute: .centerY, relatedBy: .equal, toItem: scenePreview.view,
//                         attribute: .centerY, multiplier: 1, constant: 0),
//      NSLayoutConstraint(item: reactionsStackview, attribute: .leading, relatedBy: .equal, toItem: scenePreview.view,
//                         attribute: .leading, multiplier: 1, constant: 16),
//    ])
  }

  // MARK: Studio actions
  /// Triggered when the user cancels a scene that he directed (i.e. when he didn't the photo)
  @objc private func didCancel() {
    viewModel.didCancel()
  }

  /// Switches between back and front cameras.
  @objc private func switchCamera() {
    swiftyCam.switchCamera()
  }

  /// Sends the current directed scene to our backend for saving.
  @objc private func willSend() {
    viewModel.willSend()
  }

  /// Goes back to edit the previous media, from which the user can reach the current one.
  @objc private func displayingParentMedia() {
    viewModel.displayingParentMedia()
  }

  @objc private func didChose(_ sender: UIButton) {
    let emotion = Emotion.values.filter { sender.title(for: .normal) == $0.emoji }.first
    guard emotion != nil else {
      App.log.error("Could not infer emotion.")
      return
    }
    viewModel.didChose(reaction: emotion!)
  }
}

// MARK: StudioViewModelDelegate
extension StudioViewController: StudioViewModelDelegate {
  func leaveStudio() {
    tabBarController?.selectedIndex = MainTabController.repertoireIndex
  }

  func hideMedia() {
    // Remove previous preview
    if mediaViewController != nil {
      UIHelper.remove(viewController: mediaViewController!)
      mediaViewController = nil
    }
    App.detecionModule.stop()
    reactionLabel.isHidden = true

    Timer.scheduledTimer(withTimeInterval: SceneViewModel.detetionDelaySeconds, repeats: false,
                         block: { _ in self.initSwiftyCam() })
  }

  func display(media: Media) {
    // Add media preview
    mediaViewController = MediaViewController.instantiate(with: media)
    guard mediaViewController != nil else {
      return
    }
    scenePreview.addChildViewController(mediaViewController!)
    scenePreview.view.addSubview(mediaViewController!.view)
    scenePreview.view.sendSubview(toBack: mediaViewController!.view)
    mediaViewController!.isVisible = true

    // Delete swifty cam
    UIHelper.remove(viewController: swiftyCam)
    swiftyCam = nil

    // Starts detection
    Timer.scheduledTimer(withTimeInterval: SceneViewModel.detetionDelaySeconds, repeats: false,
                         block: { _ in App.detecionModule.start() })
  }

  func didSend() {
    if scenePreview is VideoViewController {
      (scenePreview as! VideoViewController).player?.pause()
    }
  }

  func show(alert: String, title: String, okAction: String) {
    presentAlert(title: title, message: alert, okAction: okAction)
  }
}

// MARK: SwiftCamViewControllerDelegate
extension StudioViewController: SwiftyCamViewControllerDelegate {
  func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
    viewModel.didCapture(imageData: UIImageJPEGRepresentation(photo.fixOrientation(), 0.7)!)
  }

  func swiftyCam(_ swiftyCam: SwiftyCamViewController,
                 didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
//    viewModel.didStartRecordingVideo()
  }

  func swiftyCam(_ swiftyCam: SwiftyCamViewController,
                 didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
//    viewModel.didFinishRecordingVideo()
  }

  func swiftyCam(_ swiftyCam: SwiftyCamViewController,
                 didFinishProcessVideoAt url: URL) {
//    viewModel.didFinishProcessVideo(url: url)
  }
}

extension StudioViewController: ReactionDetectionDelegate {
  func didDetect(reaction: Emotion, mostLikely: Bool) {
    if !reactionLabel.isHidden || !mostLikely {
      return
    }
    reactionLabel.text = reaction.emoji
    let path = Bundle.main.path(forResource: "react", ofType:"mp3")!
    let url = URL(fileURLWithPath: path)
    do {
      self.player = try AVAudioPlayer(contentsOf: url)
      self.player?.numberOfLoops = 1
      self.player?.prepareToPlay()
      self.player?.play()
    } catch let error as NSError {
      App.log.report("Couldn't play react sound.", withError: error)
    }
    reactionLabel.isHidden = false
    view.bringSubview(toFront: reactionLabel)
  }
}
