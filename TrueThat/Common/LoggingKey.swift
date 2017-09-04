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
/// - displayedReactable: last reactable that was displayed
/// - directedReactable: last reactable that was directed in the studio
/// - viewController: current view controller (that implements `BaseViewController`).
enum LoggingKey: String {
  case authUser
  case displayedReactable
  case directedReactable
  case viewController
  case lastNetworkRequest
}
