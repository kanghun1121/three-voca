//
//  StubRequestable.swift
//  CoreTests
//
//  Created by 강대훈 on 7/6/26.
//  Copyright © 2026 FiveVoca. All rights reserved.
//

import Foundation

@testable import Core

/// 테스트용 최소 `Requestable` 구현.
struct StubRequestable: Requestable {
    var baseURL = URL(string: "https://example.com")!
    var path = "/stub"
    var method: HTTPMethod = .get
    var requiresAuthentication = true
}
