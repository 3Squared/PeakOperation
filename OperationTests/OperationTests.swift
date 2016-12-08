//
//  OperationTests.swift
//  OperationTests
//
//  Created by Sam Oakley on 08/12/2016.
//  Copyright © 2016 3Squared. All rights reserved.
//

import XCTest
import THRResult
@testable import Operation

class OperationTests: XCTestCase {
    
    func testDependancies() {
        let expect = expectation(description: "")
        
        let trueOperation = BlockResultOperation {
            return true
        }
        
        let negatingOperation = MapResultOperation<Bool, Bool> { previous in
            do {
                let boolean = try previous.resolve()
                return Result { return !boolean }
            } catch {
                return Result { throw error }
            }
        }
        
        negatingOperation.addResultBlock { result in
            do {
                let boolean = try result.resolve()
                XCTAssertFalse(boolean)
                expect.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        trueOperation.then(do: negatingOperation).enqueue()
        
        waitForExpectations(timeout: 1)
    }
    
    func testMultipleResultBlocks() {
        let expect1 = expectation(description: "")
        let expect2 = expectation(description: "")
        
        let operation = BlockResultOperation {
            return true
        }
        
        operation.addResultBlock { result in
            expect1.fulfill()
        }
        
        operation.addResultBlock { result in
            expect2.fulfill()
        }
        
        operation.enqueue()
        
        waitForExpectations(timeout: 1)
    }
    
    
    func testOperationFailureWithRetry() {
        let expect = expectation(description: "")
        
        let operation = TestRetryOperation()
        
        var runCount = 0
        operation.retryStrategy = { failureCount in
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

public enum TestError: Error {
    case justATest
}

open class TestRetryOperation: RetryingOperation<AnyObject> {
    open override func run() {
        operationResult = Result { throw TestError.justATest }
        finish()
    }
}

