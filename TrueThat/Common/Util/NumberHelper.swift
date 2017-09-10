//
//  NumberHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 01/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class NumberHelper {

  /// Suffixes for various magnitudes of numeric sizes.
  private static let suffixes: [(Int64, String)] = [
    (1000, "k"),
    (1000 * 1000, "m"),
    (1000 * 1000 * 1000, "b"),
    (1000 * 1000 * 1000 * 1000, "t")]

  /// Truncates integers into short strings.
  ///
  /// - Parameter num: to truncate
  /// - Returns: the leading digits of `num` and a trailing letter. i.e. `2.4k` or `34m`.
  static func truncate(_ num: Int64) -> String {
    let isNegative = num < 0
    let positiveNum = num < 0 ? -num : num
    let thresholdAndSuffix = suffixes.filter { threshold, _ in return threshold <= positiveNum}.last
    var truncated = positiveNum
    var postDecimal = 0 as Int64
    if (thresholdAndSuffix != nil) {
      truncated = positiveNum / thresholdAndSuffix!.0
      if (truncated < 10) {
        postDecimal = (positiveNum / (thresholdAndSuffix!.0 / 10)) % 10 as Int64
      }
    }
    return format(truncated: truncated, isNegative: isNegative,
                  suffix: thresholdAndSuffix?.1, postDecimal: postDecimal)
  }

  /// Combines the input into a formatted string.
  ///
  /// - Parameters:
  ///   - truncated: the most significant digit(s) of `num`
  ///   - isNegative: whether `num < 0`
  ///   - suffix: matching suffix to append
  ///   - postDecimal: the most significant digit that is not found in `truncated`
  /// - Returns: formatted string that represents truncated `num`.
  private static func format(truncated: Int64, isNegative: Bool,
                             suffix: String?, postDecimal: Int64) -> String {
    var formattedTruncation = isNegative ? "-" : ""
    formattedTruncation += String(truncated)
    if (postDecimal > 0) {
        formattedTruncation += "." + String(postDecimal)
    }
    if suffix != nil {
      formattedTruncation += suffix!
    }
    return formattedTruncation
  }
}
