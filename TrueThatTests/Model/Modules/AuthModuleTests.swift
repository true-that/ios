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
  var fakeKeychain: FakeKeychainModule!
  var authDelegate: AuthTestsDelegate!
  var authModule: AuthModule!
  var user: User!
  var didBackendCall: Bool!
  
  override func setUp() {
    super.setUp()
    stub(condition: isPath(AuthApi.path)) {request -> OHHTTPStubsResponse in
      self.didBackendCall = true
      let stubData = try! JSON(self.user.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type":"application/json"])
    }
    didBackendCall = false
    authDelegate = AuthTestsDelegate()
    authModule = AuthModule()
    authModule.delegate = authDelegate
    fakeKeychain = FakeKeychainModule()
    App.keychainModule = fakeKeychain
  }
  
  func testAlreadyAuthOk() {
    authModule.current = User(id: 1, firstName: "spartan", lastName: "professionless", deviceId: "2")
    authModule.auth()
    expect(self.authDelegate.authOk).to(beTrue())
    expect(self.didBackendCall).to(beFalse())
  }
  
  func testRestoreLastSession() throws {
    fakeKeychain.save(data: JSON(from: User(id: 1, firstName: "spartan",
                                            lastName: "professionless", deviceId: "2")).rawData(),
        for: AuthModule.userKey)
    authModule.auth()
    expect(self.authDelegate.authOk).to(beTrue())
    expect(self.didBackendCall).to(beFalse())
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
