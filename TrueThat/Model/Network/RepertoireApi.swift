//
//  RepertoireApi.swift
//  TrueThat
//
//  Created by Ohad Navon on 07/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import SwiftyJSON

/// [backend endpoint]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/servlet/RepertoireServlet.java
/// Api interface to fetch current user's {Scene}s from our [backend endpoint].
class RepertoireApi {
  /// Subpath relative to base backend endpoint.
  public static let path = "/repertoire"

  /// Full URL of backend endpoint from which to fetch scenes.
  static var fullUrl: String {
    return Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String + RepertoireApi.path
  }

  /// Fetching {Scene}s from our backend endpoint
  ///
  /// - Parameter user: for which to fetch scenes.
  /// - Returns: A reactive producer that invokes success and failure callbacks.
  public static func fetchScenes(for user: User) -> SignalProducer<[Scene], NSError> {
    return SignalProducer { observer, _ in
      var request = try! URLRequest(url: RepertoireApi.fullUrl, method: .post)
      request.httpBody = try! JSON(from: user).rawData()
      // TODO: cancel request when view disappears
      Alamofire.request(request).responseJSON(completionHandler: { response in
        switch response.result {
        case .success:
          observer.send(value: JSON(response.result.value!).arrayValue
            .map { Scene(json: $0) })
          observer.sendCompleted()
        case .failure:
          observer.send(error: response.result.error as NSError!)
        }
      }).log()
    }
  }
}
