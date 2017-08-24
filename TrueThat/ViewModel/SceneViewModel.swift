//
//  PoseViewModel.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class PoseViewModel: ReactableViewModel {
  // MARK: Properties
  public var imageSignedUrl: String?
  private var pose: Pose {
    return model as! Pose
  }
  var mediaDelegate: PoseMediaDelegate {
    return delegate as! PoseMediaDelegate
  }
  
  // MARK: Initialization
  override init(with reactable: Reactable) {
    super.init(with: reactable)
    imageSignedUrl = pose.imageSignedUrl
  }
  
  // MARK: Lifecycle
  override func didLoad() {
    super.didLoad()
    mediaDelegate.loadPoseImage()
  }
}

protocol PoseMediaDelegate {
  
  /// Notifies the view controller to load an image from `imageSignedUrl`.
  func loadPoseImage()
}
