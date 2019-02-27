//
//  GroupTests.swift
//  PeakOperation-iOSTests
//
//  Created by Sam Oakley on 27/02/2019.
//  Copyright © 2019 3Squared. All rights reserved.
//

import XCTest
import PeakResult
#if os(iOS)
@testable import PeakOperation_iOS
#else
@testable import PeakOperation_macOS
#endif

class GroupTests: XCTestCase {

    func testGroupOperationSuccess() {
        let expect = expectation(description: "")
        
        let firstOperation = BlockResultOperation {
            return "Hello"
        }
        
        let secondOperation = BlockMapOperation<String, String> { input in
            return Result { try "\(input.resolve()) World!" }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group()
        
        group1.addResultBlock { result in
            do {
                let _ = try result.resolve()
                expect.fulfill()
            } catch {
                XCTFail()
            }
        }
        group1.enqueue()
        
        waitForExpectations(timeout: 10)
    }
    
    func testGroupOperationFirstFailure() {
        let expect = expectation(description: "")
        
        let firstOperation = BlockMapOperation<Void, String> { _ in
            return Result { throw TestError.justATest }
        }
        
        let secondOperation = BlockMapOperation<String, String> { input in
            return Result { try "\(input.resolve()) World!" }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group()
        
        
        let group2 = BlockMapOperation<Void, String> { _ in
            return Result { "Lorem Ipsum." }
            }.group()
        
        
        group2.addResultBlock { result in
            do {
                let _ = try result.resolve()
                XCTFail()
            } catch {
                expect.fulfill()
            }
        }
        
        group1
            .passesResult(to: group2)
            .enqueue()
        
        
        waitForExpectations(timeout: 10)
    }
    
    
    func testGroupOperationSecondFailure() {
        let expect = expectation(description: "")
        
        let firstOperation = BlockMapOperation<Void, String> { input in
            return Result { try "\(input.resolve()) World!" }
        }
        
        let secondOperation = BlockMapOperation<String, String> { _ in
            return Result { throw TestError.justATest }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group()
        
        group1.addResultBlock { result in
            do {
                let _ = try result.resolve()
                XCTFail()
            } catch {
                expect.fulfill()
            }
        }
        group1.execute()
        
        waitForExpectations(timeout: 10)
    }

}
