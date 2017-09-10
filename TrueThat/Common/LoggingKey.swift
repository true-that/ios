//
//  LoggingKey.swift
//  TrueThat
//
//  Created by Ohad Navon on 04/09/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

/// Logging keys for Crashalytics
///
/// - authUser: user used for auth request
/// - displayedScene: last scene that was displayed
/// - directedScene: last scene that was directed in the studio
/// - viewController: current view controller (that implements `BaseViewController`).
enum LoggingKey: String {
  case authUser
  case displayedScene
  case directedScene
  case viewController
  case lastNetworkRequest
}
