//
//  StringHelper.swift
//  TrueThat
//
//  Created by Ohad Navon on 03/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation

class StringHelper {
  
  /// - Parameter s: to convert
  /// - Returns: capitalize every first character of every word in `s`.
  public static func toTitleCase(_ s: String) -> String {
    let words = s.components(separatedBy: " ")
    let firstCharIndex = s.index(s.startIndex, offsetBy: 1)
    return words
      .map{$0.substring(to: firstCharIndex).uppercased() + $0.substring(from: firstCharIndex).lowercased()}
      .joined(separator: " ")
  }
  
  /// Valid names satisfy the following conditions:
  /// - They only contain english letters and spaces.
  /// - They have both first and last name.
  /// - Both first and last are at least 2 letters long.
  ///
  /// - Parameter fullName: of a human.
  /// - Returns: whether the given name can formulate first and last names for a `User`.
  public static func isValid(fullName: String) -> Bool {
    let trimmed = fullName.lowercased().trimmingCharacters(in: .whitespaces)
    let firstName = extractFirstName(of: trimmed);
    let lastName = extractLastName(of: trimmed);
    // One letter names are invalid.
    let isFirstNameValid = isAlpha(firstName) && firstName.characters.count > 1;
    let isLastNameValid = isAlpha(lastName) && lastName.characters.count > 1;
    return isFirstNameValid && isLastNameValid;
  }

  /// - Parameter fullName: of a happy human being
  /// - Returns: the first word of the name.
  public static func extractFirstName(of fullName: String) -> String {
    return fullName.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")[0].lowercased()
  }
  
  /// - Parameter fullName: of a Game of Thrones loving person.
  /// - Returns: the entire `fullName` but its first word.
  public static func extractLastName(of fullName: String) -> String {
    var lastName = ""
    if fullName.range(of: " ") != nil {
      let words = fullName.components(separatedBy: " ")
      lastName = words[1...words.count - 1].filter{!$0.isEmpty}.joined(separator: " ")
    }
    return lastName.lowercased();
  }
  
  /// - Parameter s: to assess
  /// - Returns: whether `s` is made of letters and spaces
  public static func isAlpha(_ s: String) -> Bool {
    return s.range(of: "^[a-zA-Z ]*$", options: .regularExpression) != nil
  }
}
