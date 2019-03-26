//
//  MapTests.swift
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

class MapTests: XCTestCase {

    func testMapOperationOverrideMapValueSuccess() {
        let expect = expectation(description: "")
        
        let negatingOperation = TestMapValueOperation(input: true)
        negatingOperation.addResultBlock { output in
            switch (output) {
            case .success(let boolean):
                XCTAssertFalse(boolean)
                expect.fulfill()
            default:
                XCTFail()
            }
        }
        
        negatingOperation.enqueue()
        
        waitForExpectations(timeout: 1)
    }
    
    func testMapOperationOverrideMapValueFailure() {
        let expect = expectation(description: "")
        
        let negatingOperation = TestMapValueOperation()
        negatingOperation.input = .failure(TestError.justATest)
        
        negatingOperation.addResultBlock { output in
            switch (output) {
            case .failure(TestError.justATest):
                expect.fulfill()
            default:
                XCTFail()
            }
        }
        
        negatingOperation.enqueue()
        
        waitForExpectations(timeout: 1)
    }
    
    
    func testMapOperationOverrideMapResultSuccess() {
        let expect = expectation(description: "")
        
        let negatingOperation = TestMapResultOperation(input: true)
        negatingOperation.addResultBlock { output in
            switch (output) {
            case .success(let boolean):
                XCTAssertFalse(boolean)
                expect.fulfill()
            default:
                XCTFail()
            }
        }
        
        negatingOperation.enqueue()
        
        waitForExpectations(timeout: 1)
    }
    
    
    func testMapOperationOverrideMapResultFailure() {
        let expect = expectation(description: "")
        
        let negatingOperation = TestMapResultOperation(input: true)
        negatingOperation.input = .failure(TestError.justATest)
        
        negatingOperation.addResultBlock { output in
            switch (output) {
            case .failure(TestError.alsoATest):
                expect.fulfill()
            default:
                XCTFail()
            }
        }
        
        negatingOperation.enqueue()
        
        waitForExpectations(timeout: 1)
    }

}

open class TestMapValueOperation: MapOperation<Bool, Bool> {
    open override func map(input: Bool) -> Result<Bool, Error> {
        return .success(!input)
    }
}

open class TestMapResultOperation: MapOperation<Bool, Bool> {
    open override func map(input: Result<Bool, Error>) -> Result<Bool, Error> {
        switch input {
        case .success(let value):
            return .success(!value)
        case .failure(_):
            return .failure(TestError.alsoATest)
        }
    }
}
