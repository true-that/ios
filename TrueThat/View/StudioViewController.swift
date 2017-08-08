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
  
  var captureDevice: AVCaptureDevice?
  var previewView: UIView!
  var captureSession: AVCaptureSession?
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var capturePhotoOutput: AVCapturePhotoOutput?
  @IBOutlet weak var captureButton: UIImageView!
  @IBOutlet weak var cancelButton: UIImageView!
  @IBOutlet weak var switchCameraButton: UIImageView!
  @IBOutlet weak var sendButton: UIImageView!
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if viewModel == nil {
      viewModel = StudioViewModel()
      viewModel.delegate = self
    }
    
    initButtons()
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      // Dont initialize camera on Simulator
      self.view.backgroundColor = Color.shadow.value
    #else
      initCamera()
    #endif
    
    // Navigation swipe gestures
    let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.navigateToRepertoire))
    swipeUp.direction = .up
    self.view.addGestureRecognizer(swipeUp)
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.navigateToTheater))
    swipeDown.direction = .down
    self.view.addGestureRecognizer(swipeDown)
  }
  
  // MARK: Initialization
  private func initCamera() {
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the
    // video as the media type parameter
    if captureDevice == nil {
      captureDevice = AVCaptureDevice.defaultDevice(
        withDeviceType: .builtInWideAngleCamera,
        mediaType: AVMediaTypeVideo,
        position: .front)
    }
    do {
      // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      // Initialize the captureSession object
      captureSession = AVCaptureSession()
      
      // Set the input devcie on the capture session
      captureSession?.addInput(input)
      
      // Get an instance of ACCapturePhotoOutput class
      capturePhotoOutput = AVCapturePhotoOutput()
      capturePhotoOutput?.isHighResolutionCaptureEnabled = true
      
      // Set the output on the capture session
      captureSession?.addOutput(capturePhotoOutput)
      
      //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      if previewView != nil {
        previewView.removeFromSuperview()
        previewView = nil
      }
      previewView = UIView()
      previewView!.layer.addSublayer(videoPreviewLayer!)
      self.view.addSubview(previewView)
      // Preview should be behind buttons
      previewView.layer.zPosition = -1
      
      //start video capture
      captureSession?.startRunning()
    } catch {
      App.log.error("Failed to initialize camera: \(error)")
    }
  }
  
  private func initButtons() {
    // Enable for interaction
    captureButton.isUserInteractionEnabled = true
    cancelButton.isUserInteractionEnabled = true
    switchCameraButton.isUserInteractionEnabled = true
    sendButton.isUserInteractionEnabled = true
    
    // Initialize tap gestures
    captureButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.capturePhoto)))
    cancelButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.didCancel)))
    switchCameraButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.switchCamera)))
    sendButton.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.didApprove)))
    
    // Initialize images
    captureButton.image = UIImage(named: "capture_image.png")
    cancelButton.image = UIImage(named: "cross.png")
    switchCameraButton.image = UIImage(named: "switch_camera.png")
    sendButton.image = UIImage(named: "send_reactable.png")
    
    // Initialize visibility hooks
    captureButton.reactive.isHidden <~ viewModel.captureButtonHidden
    switchCameraButton.reactive.isHidden <~ viewModel.switchCameraButtonHidden
    cancelButton.reactive.isHidden <~ viewModel.cancelButtonHidden
    sendButton.reactive.isHidden <~ viewModel.sendButtonHidden
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
  
  // MARK: Camera
  
  /// Starts capture sequence for the device harware camera.
  @objc private func capturePhoto() {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      // Dont capture a real photo on the simulator
      viewModel.didCapture(imageData: Data())
    #else
      // Make sure capturePhotoOutput is valid
      guard let capturePhotoOutput = self.capturePhotoOutput else { return }
      
      // Get an instance of AVCapturePhotoSettings class
      let photoSettings = AVCapturePhotoSettings()
      
      // Set photo settings for our need
      photoSettings.isAutoStillImageStabilizationEnabled = true
      photoSettings.isHighResolutionPhotoEnabled = true
      photoSettings.flashMode = .auto
      
      // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
      capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
      
      // Freezes the camera preview
      captureSession?.stopRunning()
    #endif
  }
  
  /// Triggered when the user cancels a reactable that he directed (i.e. when he didn't the photo)
  @objc private func didCancel() {
    viewModel.willDirect()
  }
  
  /// Switches between back and front cameras.
  @objc private func switchCamera() {
    if captureDevice == nil || captureDevice!.position == .back {
      captureDevice = AVCaptureDevice.defaultDevice(
        withDeviceType: .builtInWideAngleCamera,
        mediaType: AVMediaTypeVideo,
        position: .front)
    } else {
      captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    }
    initCamera()
  }
  
  @objc private func didApprove() {
    viewModel.didSend()
  }
}

// MARK: StudioViewModelDelegate
extension StudioViewController: StudioViewModelDelegate {
  func restorePreview() {
    if captureSession != nil && !captureSession!.isRunning {
      captureSession?.startRunning()
    }
  }
  
  func leaveStudio() {
    self.present(
      UIStoryboard(name: "Main", bundle: self.nibBundle).instantiateViewController(
        withIdentifier: "TheaterScene"),
      animated: true, completion: nil)
  }
}

// MARK: AVCapturePhotoCaptureDelegate
extension StudioViewController: AVCapturePhotoCaptureDelegate {
  func capture(_ captureOutput: AVCapturePhotoOutput,
               didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
               previewPhotoSampleBuffer: CMSampleBuffer?,
               resolvedSettings: AVCaptureResolvedPhotoSettings,
               bracketSettings: AVCaptureBracketedStillImageSettings?,
               error: Error?) {
    // Make sure we get some photo sample buffer
    guard error == nil,
      let photoSampleBuffer = photoSampleBuffer else {
        App.log.error("Error capturing photo: \(String(describing: error))")
        return
    }
    
    // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
    guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(
      forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
      else {
        return
    }
    
    // Inform view model of captured photo
    viewModel.didCapture(imageData: imageData)
  }
}
