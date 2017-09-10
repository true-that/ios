//
//  AuthApi.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import SwiftyJSON

/// [backend]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/servlet/AuthServlet.java
/// Authenticating a user against our [backend].
class AuthApi {
  /// Subpath relative to base backend endpoint.
  static public let path = "/auth"

  /// Full URL of backend endpoint from which to fetch scenes.
  static var fullUrl: String {
    return Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String + AuthApi.path
  }
  /// Authenticating a user against our [backend].
  ///
  /// - Parameter user: to authenticate.
  /// - Returns: A reactive producer that invokes success and failure callbacks.
  public static func auth(for user: User) -> SignalProducer<User, NSError> {
    return SignalProducer { observer, _ in
      var request = try! URLRequest(url: AuthApi.fullUrl, method: .post)
      request.httpBody = try! JSON(from: user).rawData()
      // TODO: cancel request when view disappears
      Alamofire.request(request).responseJSON(completionHandler: {response in
        switch response.result {
        case .success:
          observer.send(value: User(json: JSON(response.result.value!)))
          observer.sendCompleted()
        case .failure:
          observer.send(error: response.result.error as NSError!)
        }
      }).log()
    }
  }
}
