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
/// Api interface to fetch current user's{Reactable}s from our [backend endpoint].
class RepertoireApi {
  /// Subpath relative to base backend endpoint.
  static public let path = "/repertoire"
  
  /// Full URL of backend endpoint from which to fetch reactables.
  static var fullUrl: String {
    return Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String + RepertoireApi.path
  }
  /// Fetching {Reactable}s from our backend endpoint
  ///
  /// - Parameter user: for which to fetch reactables.
  /// - Returns: A reactive producer that invokes success and failure callbacks.
  public static func fetchReactables(for user: User) -> SignalProducer<[Reactable], NSError> {
    return SignalProducer { observer, disposable in
      var request = try! URLRequest(url: RepertoireApi.fullUrl, method: .post)
      request.httpBody = try! JSON(from: user).rawData()
      // TODO: cancel request when view disappears
      Alamofire.request(request).responseJSON(completionHandler: {response in
        switch response.result {
        case .success:
          observer.send(value: JSON(response.result.value!).arrayValue
            .map{Reactable(json: $0)})
          observer.sendCompleted()
        case .failure:
          observer.send(error: response.result.error as NSError!)
        }
      }).log()
    }
  }
}
