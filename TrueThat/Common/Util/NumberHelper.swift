//
//  NumberHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class NumberHelper {
  private static let suffixes: [(Int64, String)] = [
    (1000, "k"),
    (1000 * 1000, "m"),
    (1000 * 1000 * 1000, "b"),
    (1000 * 1000 * 1000 * 1000, "t")]
  static func truncate(_ num: Int64) -> String {
    let isNegative = num < 0
    let positiveNum = num < 0 ? -num : num
    let thresholdAndSuffix = suffixes.filter{ threshold, suffix in return threshold <= positiveNum}.last
    var truncated = positiveNum
    var postDecimal = 0 as Int64
    if (thresholdAndSuffix != nil) {
      truncated = positiveNum / thresholdAndSuffix!.0
      if (truncated < 10) {
        postDecimal = (positiveNum / (thresholdAndSuffix!.0 / 10)) % 10 as Int64
      }
    }
    return format(truncated: truncated, isNegative: isNegative,
                  thresholdAndSuffix: thresholdAndSuffix, postDecimal: postDecimal)
  }
  
  private static func format(truncated: Int64, isNegative: Bool,
                             thresholdAndSuffix: (Int64, String)?, postDecimal: Int64) -> String {
    var formattedTruncation = isNegative ? "-" : ""
    formattedTruncation += String(truncated)
    if (postDecimal > 0) {
        formattedTruncation += "." + String(postDecimal)
    }
    if (thresholdAndSuffix != nil) {
      formattedTruncation += thresholdAndSuffix!.1
    }
    return formattedTruncation
  }
}
