//
//  DateHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 31/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class DateHelper {

  /// Text for recent timestamps
  static let nowText = "now"

  /// Suffixes for various time magnitudes
  private static let suffixes = [
    (60, "m"), (60 * 60, "h"), (60 * 60 * 24, "d"),
    (60 * 60 * 24 * 30, "mon"), (60 * 60 * 24 * 365, "y"),
  ]

  /// Formats from and to UTC Date in a format that matches our backend.
  static let dateFormatter: DateFormatter = {
    var formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
    return formatter
  }()

  /// Create a UTC Date.
  ///
  /// - Parameter date: in textual representation
  /// - Returns: a UTC Date that is represented by `date`.
  static func utcDate(fromString date: String?) -> Date? {
    guard let date = date else {
      return nil
    }
    return dateFormatter.date(from: date)
  }

  /// Converts a date to its textual representation in UTC format
  ///
  /// - Parameter date: to convert
  /// - Returns: the textual representation of `date` in UTC format.
  static func utcDate(fromDate date: Date?) -> String? {
    guard let date = date else {
      return nil
    }
    return dateFormatter.string(from: date)
  }

  /// Truncates time difference into human readable string.
  ///
  /// - Parameters:
  ///   - from: earlier timestamp
  ///   - until: later timestamp
  /// - Returns: human readable time difference in the form of `1m ago` or `4d ago`.
  static func truncatedTimeAgo(from: Date?, until: Date = Date()) -> String {
    guard let from = from else {
      return nowText
    }
    let diff = Int(until.timeIntervalSince(from).rounded())
    if diff < suffixes[0].0 {
      return nowText
    }
    let thresholdAndSuffix = suffixes.filter { threshold, _ in return threshold <= diff }.last!
    let truncated = diff / thresholdAndSuffix.0
    return "\(truncated)\(thresholdAndSuffix.1) ago"
  }
}
