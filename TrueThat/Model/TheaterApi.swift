//
//  TheaterApi.swift
//  TrueThat
//
//  Created by Ohad Navon on 13/07/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import SwiftyJSON

/// [backend endpoint]: https://github.com/true-that/backend/blob/master/src/main/java/com/truethat/backend/servlet/TheaterServlet.java
/// Api interface from our [backend endpoint] to fetch {Reactable}s.
class TheaterApi {
  /// Subpath relative to base backend endpoint.
  static public let path = "/theater"
  
  /// Full URL of backend endpoint from which to fetch reactables.
  static var fullUrl: String {
    return Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String + TheaterApi.path
  }
  /// Fetching {Reactable}s from our backend endpoint
  ///
  /// - Parameter user: for which to fetch reactables.
  /// - Returns: A reactive producer that invokes success and failure callbacks.
  public static func fetchReactables(for user: User) -> SignalProducer<[Reactable], NSError> {
    return SignalProducer { observer, disposable in
      var request = try! URLRequest(url: TheaterApi.fullUrl, method: .post)
      request.httpBody = try! JSON(from: user).rawData()
      // TODO: cancel request when view disappears 
      Alamofire.request(request).responseJSON(completionHandler: {response in
        print (response.result)
        switch response.result {
        case .success:
          observer.send(value: JSON(response.result.value!).arrayValue
            .map{Reactable.instantiate(with: $0)!})
          observer.sendCompleted()
        case .failure:
          observer.send(error: response.result.error as NSError!)
        }
      })
    }
  }
}
