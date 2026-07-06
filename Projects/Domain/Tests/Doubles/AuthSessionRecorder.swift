//
//  AuthSessionRecorder.swift
//  DomainTests
//
//  Created by 강대훈 on 7/6/26.
//

import Foundation

/// `AuthSessionClient`의 closure에 연결해 호출 여부·인자를 기록하는 레코더.
final class AuthSessionRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var _setAccessTokenCallCount = 0
    private var _setRefreshTokenCallCount = 0
    private var _clearSessionCallCount = 0
    private var _lastSetAccessToken: String?
    private var _lastSetRefreshToken: String?

    var setAccessTokenCallCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _setAccessTokenCallCount
    }

    var setRefreshTokenCallCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _setRefreshTokenCallCount
    }

    var clearSessionCallCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _clearSessionCallCount
    }

    var lastSetAccessToken: String? {
        lock.lock(); defer { lock.unlock() }
        return _lastSetAccessToken
    }

    var lastSetRefreshToken: String? {
        lock.lock(); defer { lock.unlock() }
        return _lastSetRefreshToken
    }

    func recordSetAccessToken(_ token: String) {
        lock.lock()
        _setAccessTokenCallCount += 1
        _lastSetAccessToken = token
        lock.unlock()
    }

    func recordSetRefreshToken(_ token: String) {
        lock.lock()
        _setRefreshTokenCallCount += 1
        _lastSetRefreshToken = token
        lock.unlock()
    }

    func recordClearSession() {
        lock.lock()
        _clearSessionCallCount += 1
        lock.unlock()
    }
}
