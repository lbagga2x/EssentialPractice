//
//  XCTestCase+MemoryLeak.swift
//  EssentialFeedTests
//
//  Created by Lalit Bagga on 2022-02-06.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
