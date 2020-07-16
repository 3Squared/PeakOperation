//
//  RetryTests.swift
//  PeakOperation-iOSTests
//
//  Created by Sam Oakley on 27/02/2019.
//  Copyright © 2019 3Squared. All rights reserved.
//

import XCTest
#if os(iOS)
@testable import PeakOperation_iOS
#else
@testable import PeakOperation_macOS
#endif

class RetryTests: XCTestCase {

    func testOperationFailureWithRetry() {
        let expect = expectation(description: "")
        
        let operation = TestRetryOperation()
        
        var runCount = 0
        operation.retryStrategy = { failureCount, error in
            runCount += 1
            return failureCount < 3
        }
        
        operation.addResultBlock { result in
            XCTAssertEqual(runCount, 3)
            expect.fulfill()
        }
        
        operation.enqueue()
        
        waitForExpectations(timeout: 100)
    }
    
}

open class TestRetryOperation: RetryingOperation<AnyObject> {
    open override func execute() {
        output = Result { throw TestError.justATest }
        finish()
    }
}
