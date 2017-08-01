//
//  DateHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 31/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class DateHelper {
  static let nowText = "now"
  private static let suffixes = [(60, "m"), (60 * 60, "h"), (60 * 60 * 24, "d"),
                                 (60 * 60 * 24 * 30, "mon"), (60 * 60 * 24 * 365, "y")]
  static let dateFormatter: DateFormatter = {
    var formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MMM-dd'T'HH:mm:ss.SSSZ"
    formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
    return formatter
  }()
  
  static func utcDate(fromString date: String?) -> Date? {
    guard let date = date else {
      return nil
    }
    return dateFormatter.date(from: date)
  }
  
  static func utcDate(fromDate date: Date?) -> String? {
    guard let date = date else {
      return nil
    }
    return dateFormatter.string(from: date)
  }
  
  static func truncatedTimeAgo(from: Date?, until: Date = Date()) -> String {
    guard let from = from else {
      return nowText
    }
    let diff = Int(until.timeIntervalSince(from).rounded())
    if (diff < suffixes[0].0) {
      return nowText
    }
    let thresholdAndSuffix = suffixes.filter{ threshold, suffix in return threshold <= diff}.last!
    let truncated = diff / thresholdAndSuffix.0
    return "\(truncated)\(thresholdAndSuffix.1) ago"
  }
}
