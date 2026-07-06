//
//  AuthSessionClientSpy.swift
//  DomainTests
//
//  Created by 강대훈 on 7/6/26.
//

import Foundation

import DomainInterface

/// `getAccessToken`/`getRefreshToken` 반환값을 설정하고, 나머지 호출 여부·인자를 기록하는 스파이.
final class AuthSessionClientSpy: @unchecked Sendable {
    var accessTokenToReturn: String?
    var refreshTokenResult: Result<String, Error> = .success("stub-refresh-token")

    private let lock = NSLock()
    private var _getRefreshTokenCallCount = 0
    private var _setAccessTokenCallCount = 0
    private var _setRefreshTokenCallCount = 0
    private var _clearSessionCallCount = 0
    private var _lastSetAccessToken: String?
    private var _lastSetRefreshToken: String?

    var getRefreshTokenCallCount: Int {
        lock.lock(); defer { lock.unlock() }
        return _getRefreshTokenCallCount
    }

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

    var asClient: AuthSessionClient {
        AuthSessionClient(
            getAccessToken: { [self] in accessTokenToReturn },
            setAccessToken: { [self] token in
                lock.lock()
                _setAccessTokenCallCount += 1
                _lastSetAccessToken = token
                lock.unlock()
            },
            getRefreshToken: { [self] in
                lock.lock()
                _getRefreshTokenCallCount += 1
                lock.unlock()
                return try refreshTokenResult.get()
            },
            setRefreshToken: { [self] token in
                lock.lock()
                _setRefreshTokenCallCount += 1
                _lastSetRefreshToken = token
                lock.unlock()
            },
            clearSession: { [self] in
                lock.lock()
                _clearSessionCallCount += 1
                lock.unlock()
            },
            deleteAccount: {},
            authStateStream: { AsyncStream { _ in } }
        )
    }
}
