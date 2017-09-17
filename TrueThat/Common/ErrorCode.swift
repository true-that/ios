//
//  ErrorCode.swift
//  TrueThat
//
//  Created by Ohad Navon on 28/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

/// Errors enumeration.
// next available - 4
enum ErrorCode: Int {
  // MARK: Network
  case decoding = 1
  case badResponseData = 2
  // MARK: Invalid data
  case mediaTree = 3
}
