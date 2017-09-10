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
/// Api interface to fetch {Scene}s from our [backend endpoint].
class TheaterApi {
  /// Subpath relative to base backend endpoint.
  static public let path = "/theater"
  
  /// Full URL of backend endpoint from which to fetch scenes.
  static var fullUrl: String {
    return Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String + TheaterApi.path
  }
  /// Fetching {Scene}s from our backend endpoint
  ///
  /// - Parameter user: for which to fetch scenes.
  /// - Returns: A reactive producer that invokes success and failure callbacks.
  public static func fetchScenes(for user: User) -> SignalProducer<[Scene], NSError> {
    return SignalProducer { observer, disposable in
      var request = try! URLRequest(url: TheaterApi.fullUrl, method: .post)
      request.httpBody = try! JSON(from: user).rawData()
      // TODO: cancel request when view disappears 
      Alamofire.request(request).responseJSON(completionHandler: {response in
        switch response.result {
        case .success:
          observer.send(value: JSON(response.result.value!).arrayValue
            .map{Scene(json: $0)})
          observer.sendCompleted()
        case .failure:
          observer.send(error: response.result.error as NSError!)
        }
      }).log()
    }
  }
}
