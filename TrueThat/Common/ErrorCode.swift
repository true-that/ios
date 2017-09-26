//
//  ErrorCode.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

/// Error enumeration for NSError creation.
///
/// - decoding: response decoding into JSON failed.
/// - badResponseData: responsed data is bad.
/// - mediaTree: failed to create a media tree from provided nodes and edges.
/// - exportSession: failed to create export session.
/// - videoEncoding: failed to encode video into mp4 format.
enum ErrorCode: Int {
  // MARK: Network
  case decoding = 1
  case badResponseData = 2
  // MARK: Invalid data
  case mediaTree = 3
  // MARK: Encoding
  case exportSession = 4
  case videoEncoding = 5
} // next available - 6
