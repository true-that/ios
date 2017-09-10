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
  var scenePreview: MediaViewController?

  @IBOutlet weak var captureButton: SwiftyCamButton!
  @IBOutlet weak var cancelButton: UIImageView!
  @IBOutlet weak var switchCameraButton: UIImageView!
  @IBOutlet weak var sendButton: UIImageView!
  @IBOutlet weak var loadingImage: UIImageView!

  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize view model
    if viewModel == nil {
      viewModel = StudioViewModel()
      viewModel.delegate = self
    }

    // Navigation swipe gestures
    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.navigateToRepertoire))
    swipeUp.direction = .up
    self.view.addGestureRecognizer(swipeUp)
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.navigateToTheater))
    swipeDown.direction = .down
    self.view.addGestureRecognizer(swipeDown)

    initUI()
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      // Dont initialize camera on Simulator
      self.view.backgroundColor = Color.shadow.value
      // Button delegate shaould be defined externally 
    #else
      swiftyCam = SwiftyCamViewController()
      swiftyCam.defaultCamera = .front
      // Camera preview
      self.addChildViewController(swiftyCam)
      self.view.addSubview(swiftyCam.view)
      swiftyCam.view.reactive.isHidden <~ viewModel.cameraSessionHidden
      // Send preview to back
      self.view.sendSubview(toBack: swiftyCam.view)
      // Add navigation gestures
      swiftyCam.view.addGestureRecognizer(swipeUp)
      swiftyCam.view.addGestureRecognizer(swipeDown)
      swiftyCam.cameraDelegate = self
      // Capture button
      captureButton.delegate = swiftyCam
    #endif
  }

  // MARK: Initialization
  private func initUI() {
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
      UITapGestureRecognizer(target: self, action: #selector(self.didApprove)))

    // Initialize images
    viewModel.captureButtonImageName.producer.on {
      self.captureButton.setBackgroundImage(UIImage(named: $0), for: UIControlState.normal)
    }.start()
    captureButton.layer.backgroundColor = Color.shadow.withAlpha(0.0).cgColor
    cancelButton.image = UIImage(named: "cross.png")
    view.bringSubview(toFront: cancelButton)
    switchCameraButton.image = UIImage(named: "switch_camera.png")
    sendButton.image = UIImage(named: "send_scene.png")

    // Initialize visibility hooks
    captureButton.reactive.isHidden <~ viewModel.captureButtonHidden
    switchCameraButton.reactive.isHidden <~ viewModel.switchCameraButtonHidden
    cancelButton.reactive.isHidden <~ viewModel.cancelButtonHidden
    sendButton.reactive.isHidden <~ viewModel.sendButtonHidden
    loadingImage.reactive.isHidden <~ viewModel.loadingImageHidden

    // Sets up loading image
    UIHelper.initLoadingImage(loadingImage)
  }

  // MARK: View Controller Navigation
  @objc private func navigateToTheater() {
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "TheaterScene"),
      animated: true, completion: nil)
  }

  @objc private func navigateToRepertoire() {
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "RepertoireScene"),
      animated: true, completion: nil)
  }

  /// Triggered when the user cancels a scene that he directed (i.e. when he didn't the photo)
  @objc private func didCancel() {
    viewModel.willDirect()
  }

  /// Switches between back and front cameras.
  @objc private func switchCamera() {
    swiftyCam.switchCamera()
  }

  @objc private func didApprove() {
    viewModel.willSend()
  }
}

// MARK: StudioViewModelDelegate
extension StudioViewController: StudioViewModelDelegate {
  func leaveStudio() {
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "TheaterScene"),
      animated: true, completion: nil)
  }

  func displayPreview(of scene: Scene?) {
    // Remove previous preview
    if scenePreview != nil {
      scenePreview!.willMove(toParentViewController: nil)
      scenePreview!.view.removeFromSuperview()
      scenePreview!.removeFromParentViewController()
      scenePreview = nil
    }
    guard scene != nil else {
      return
    }
    // Add scene preview
    scenePreview = MediaViewController.instantiate(with: scene?.media)
    guard scenePreview != nil else {
      return
    }
    self.addChildViewController(scenePreview!)
    self.view.addSubview(scenePreview!.view)
    self.view.sendSubview(toBack: scenePreview!.view)
    scenePreview!.view.reactive.isHidden <~ viewModel.scenePreviewHidden
  }

  func didSend() {
    if scenePreview is VideoViewController {
      (scenePreview as! VideoViewController).player?.pause()
    }
  }

  func show(alert: String, withTitle: String, okAction: String) {
    let alertController = UIAlertController(title: withTitle, message: alert,
                                            preferredStyle: .alert)
    let okAction = UIAlertAction(title: okAction, style: .default, handler: nil)
    alertController.addAction(okAction)
    self.present(alertController, animated: true, completion: nil)
  }
}

// MARK: SwiftCamViewControllerDelegate
extension StudioViewController: SwiftyCamViewControllerDelegate {
  func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
    viewModel.didCapture(imageData: UIImageJPEGRepresentation(photo, 0.7)! )
  }

  func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
    viewModel.didStartRecordingVideo()
  }

  func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
    viewModel.didFinishRecordingVideo()
  }

  func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
    viewModel.didFinishProcessVideo(url: url)
  }
}
