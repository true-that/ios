//
//  String+Extensions.swift
//  TrueThat
//
//  Created by Ohad Navon on 22/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

extension String {
  /// - Returns: capitalize every first character of every word in self. Expects spaced words
  public func titleCased() -> String {
    let words = self.components(separatedBy: " ")
    let firstCharIndex = self.index(self.startIndex, offsetBy: 1)
    return words
      .map {$0.substring(to: firstCharIndex).uppercased() + $0.substring(from: firstCharIndex).lowercased()}
      .joined(separator: " ")
  }

  /// - Returns: snake case form of self. `heyThere` -> `hey_there`. Expects camel cased string.
  public func snakeCased() -> String? {
    let pattern = "([a-z0-9])([A-Z])"

    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: self.characters.count)
    return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
  }

  /// - Returns: camel case form of self. `hey_there` -> `heyThere`. Expects snake cased string.
  public func camelCased() -> String {
    let words = self.components(separatedBy: "_")
    // If there is a single snake case part, then
    if words.count <= 1 {
      return self.lowercased()
    }
    let firstCharIndex = self.index(self.startIndex, offsetBy: 1)
    let camelCasedWords = words[1...words.count - 1].map {$0.substring(to: firstCharIndex).uppercased() + $0.substring(from: firstCharIndex).lowercased()}
    // Concatenate lowercased first word and title cased rest of the words.
    return ([words[0].lowercased()] + camelCasedWords).joined(separator: "")
  }
}
