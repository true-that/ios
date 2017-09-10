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
    stub(condition: isPath(AuthApi.path)) {_ -> OHHTTPStubsResponse in
      self.didBackendCall = true
      let stubData = try! JSON(self.user.toDictionary()).rawData()
      return OHHTTPStubsResponse(data: stubData, statusCode: 200,
                                 headers: ["Content-Type": "application/json"])
    }
    didBackendCall = false
    authDelegate = AuthTestsDelegate()
    authModule = AuthModule()
    authModule.delegate = authDelegate
    fakeKeychain = FakeKeychainModule()
    App.keychainModule = fakeKeychain
    user = User(id: 1, firstName: "dellores", lastName: "hidyhoe", deviceId: App.deviceModule.deviceId)
  }

  func resetState() {
    didBackendCall = false
    authDelegate = AuthTestsDelegate()
    authModule.delegate = authDelegate
  }

  func doingAuth() {
    do {
      try fakeKeychain.save(JSON(from: user).rawData(), key: AuthModule.userKey)
    } catch {}
    authModule.current = user
    authModule.auth()
    assertAuthOk()
  }

  func assertAuthOk() {
    expect(self.authDelegate.authOk).toEventually(beTrue())
    expect(self.authDelegate.authFail).to(beNil())
    expect(self.authModule.current).to(equal(self.user))
    expect(User(json: JSON(App.keychainModule.get(AuthModule.userKey)!))).to(equal(self.user))
  }

  func assertAuthFailed() {
    expect(self.authDelegate.authFail).toEventually(beTrue())
    expect(self.authDelegate.authOk).to(beNil())
    expect(self.authModule.current).to(beNil())
    expect(self.authModule.isAuthOk).to(beFalse())
  }

  func testSignInAlreadyAuthOk() {
    doingAuth()
    assertAuthOk()
    didBackendCall = false
    authModule.signIn()
    expect(self.didBackendCall).to(beFalse())
    assertAuthOk()
  }

  func testSignInFromLastSession() throws {
    try fakeKeychain.save(JSON(from: user).rawData(), key: AuthModule.userKey)
    authModule.signIn()
    assertAuthOk()
    expect(self.didBackendCall).to(beTrue())
  }

  func testSignInBasedOnDeviceId() {
    authModule.signIn()
    assertAuthOk()
    expect(self.didBackendCall).to(beTrue())
  }

  func testAlreadyAuthOk() {
    doingAuth()
    authModule.auth()
    assertAuthOk()
    expect(self.didBackendCall).to(beFalse())
  }

  func testRestoreLastSession() throws {
    try fakeKeychain.save(JSON(from: user).rawData(), key: AuthModule.userKey)
    authModule.auth()
    assertAuthOk()
    expect(self.didBackendCall).to(beTrue())
  }

  func testFailedAuth() {
    authModule.auth()
    assertAuthFailed()
    expect(self.didBackendCall).to(beFalse())
  }

  func testSignOut() {
    doingAuth()
    assertAuthOk()
    resetState()
    authModule.signOut()
    assertAuthFailed()
    expect(self.fakeKeychain.get(AuthModule.userKey)).to(beNil())
  }

  func testSuccessfulSignUp() {
    authModule.signUp(fullName: user.displayName)
    assertAuthOk()
  }

  func testSignUpBadResponse() {
    stub(condition: isPath(AuthApi.path)) {_ -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(error: NSError(domain: Bundle.main.bundleIdentifier!,
                                                code: 1, userInfo: nil))
    }
    authModule.signUp(fullName: user.displayName)
    assertAuthFailed()
  }

  func testSignUpBadData() {
    stub(condition: isPath(AuthApi.path)) {_ -> OHHTTPStubsResponse in
      return OHHTTPStubsResponse(data: Data(), statusCode:200,
                                 headers: ["Content-Type": "application/json"])
    }
    authModule.signUp(fullName: user.displayName)
    assertAuthFailed()
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
