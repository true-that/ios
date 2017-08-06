//
//  FakeAuthModuleTests.swift
//  TrueThat
//
//  Created by Ohad Navon on 06/08/2017.
//  Copyright © 2017 TrueThat. All rights reserved.
//

import XCTest
@testable import TrueThat
import OHHTTPStubs
import SwiftyJSON
import Nimble


class FakeAuthModuleTests: BaseTests {
  var authDelegate: AuthTestsDelegate!
  var authModule: AuthModule!
  
  override func setUp() {
    super.setUp()
    authDelegate = AuthTestsDelegate()
    authModule = FakeAuthModule()
    authModule.delegate = authDelegate
  }
  
  func testSuccessfulAuth() {
    let user = User(id: 1, firstName: "spartan", lastName: "professionless", deviceId: "2")
    authModule.current = user
    authModule.saveSession()
    authModule.current = nil
    authModule.auth()
    expect(self.authDelegate.authOk).to(beTrue())
    expect(self.authModule.current).to(equal(user))
  }
  
  func testSuccessfulSignUpThenOutThenIn() {
    let responded = User(id: 1, firstName: "dellores", lastName: "hidyhoe", deviceId: App.deviceModule.deviceId)
    stub(condition: isPath(AuthApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(responded.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    authModule.signUp(fullName: "dellores hidyhoe")
    expect(self.authDelegate.authOk).toEventually(beTrue())
    expect(self.authModule.current).to(equal(responded))
    authModule.current = nil
    expect(self.authModule.isAuthOk).to(beFalse())
    authDelegate.authOk = nil
    authModule.signIn()
    expect(self.authDelegate.authOk).to(beTrue())
    expect(self.authModule.current).to(equal(responded))
  }
  
  class AuthTestsDelegate: AuthDelegate {
    var authOk: Bool?
    var authFail: Bool?
    
    func didAuthOk() {
      authOk = true
    }
    
    func didAuthFail() {
      authFail = true
    }
  }
}
