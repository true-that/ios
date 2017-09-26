//
//  MediaViewController.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import UIKit

class MediaViewController: UIViewController {
  // MARK: Properties
  var delegate: MediaViewControllerDelegate?
  var finished = false
  var logTag = "MediaViewController"

  // MARK: Initialization
  public static func instantiate(with media: Media?) -> MediaViewController? {
    switch media {
    case is Video:
      return VideoViewController.instantiate(media as! Video)
    case is Photo:
      return PhotoViewController.instantiate(media as! Photo)
    default:
      return nil
    }
  }

  // MARK: Lifecycle
  override func viewDidLoad() {
    logTag = String(describing: type(of: self))
    super.viewDidLoad()
    App.log.debug("\(logTag): viewDidLoad")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    App.log.debug("\(logTag): viewWillAppear")
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    App.log.debug("\(logTag): viewDidAppear")
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillAppear(animated)
    App.log.debug("\(logTag): viewWillDisappear")
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    App.log.debug("\(logTag): viewDidDisappear")
  }
}

protocol MediaViewControllerDelegate {

  /// Invoked once the video had been successfully downloaded.
  func didDownloadMedia()

  /// Show loading image to indicate content is being downloaded
  func showLoader()

  /// Hide loading image
  func hideLoader()

  /// Invoked once the media is finished, such as when a video ends.
  func didFinish()
}
