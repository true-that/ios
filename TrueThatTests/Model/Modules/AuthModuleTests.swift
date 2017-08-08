//
//  AuthModuleTests.swift
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


class AuthModuleTests: BaseTests {
  var authDelegate: AuthTestsDelegate!
  var authModule: AuthModule!
  
  override func setUp() {
    super.setUp()
    authDelegate = AuthTestsDelegate()
    authModule = AuthModule()
    authModule.delegate = authDelegate
  }
  
  func testSuccessfulAuth() {
    authModule.current = User(id: 1, firstName: "spartan", lastName: "professionless", deviceId: "2")
    authModule.auth()
    expect(self.authDelegate.authOk).to(beTrue())
  }
  
  func testFailedAuth() {
    authModule.auth()
    expect(self.authDelegate.authFail).to(beTrue())
  }
  
  func testSignOut() {
    authModule.current = User(id: 1, firstName: "spartan", lastName: "professionless", deviceId: "2")
    authModule.auth()
    expect(self.authDelegate.authOk).to(beTrue())
    authModule.signOut()
    expect(self.authModule.isAuthOk).to(beFalse())
    expect(self.authDelegate.authFail).to(beTrue())
  }
  
  func testSuccessfulSignUp() {
    let responded = User(id: 1, firstName: "dellores", lastName: "hidyhoe", deviceId: App.deviceModule.deviceId)
    stub(condition: isPath(AuthApi.path)) {request -> OHHTTPStubsResponse in
      let stubData = try! JSON(responded.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    authModule.signUp(fullName: "dellores hidyhoe")
    expect(self.authDelegate.authOk).toEventually(beTrue())
    expect(self.authModule.current).to(equal(responded))
  }
  
  func testSignUpBadResponse() {
    stub(condition: isPath(AuthApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: BaseError.network)
    }
    authModule.signUp(fullName: "dellores hidyhoe")
    expect(self.authDelegate.authFail).toEventually(beTrue())
    expect(self.authModule.current).to(beNil())
  }
  
  func testSignUpBadData() {
    stub(condition: isPath(AuthApi.path)) {request -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type":"application/json"])
    }
    authModule.signUp(fullName: "dellores hidyhoe")
    expect(self.authDelegate.authFail).toEventually(beTrue())
    expect(self.authModule.current).to(beNil())
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