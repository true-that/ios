//
//  Helper.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class Helper {
  static let dateFormatter: DateFormatter = {
    var formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
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
}
