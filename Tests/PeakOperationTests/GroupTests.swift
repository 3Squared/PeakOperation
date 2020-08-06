//
//  GroupTests.swift
//  PeakOperation-iOSTests
//
//  Created by Sam Oakley on 27/02/2019.
//  Copyright © 2019 3Squared. All rights reserved.
//

import XCTest
@testable import PeakOperation

class GroupTests: XCTestCase {

    func testGroupOperationSuccess() {
        let expect = expectation(description: "")
        
        let firstOperation = BlockResultOperation {
            return "Hello"
        }
        
        let secondOperation = BlockMapOperation<String, String> { input in
            return Result { try "\(input.get()) World!" }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group()
        
        group1.addResultBlock { result in
            do {
                let _ = try result.get()
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
            return Result { try "\(input.get()) World!" }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group()
        
        
        let group2 = BlockMapOperation<Void, String> { _ in
            return Result { "Lorem Ipsum." }
            }.group()
        
        
        group2.addResultBlock { result in
            do {
                let _ = try result.get()
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
            return Result { try "\(input.get()) World!" }
        }
        
        let secondOperation = BlockMapOperation<String, String> { _ in
            return Result { throw TestError.justATest }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group()
        
        group1.addResultBlock { result in
            do {
                let _ = try result.get()
                XCTFail()
            } catch {
                expect.fulfill()
            }
        }
        group1.execute()
        
        waitForExpectations(timeout: 10)
    }

    func testGroupOperationCancellationCancelsChildren() {
        let expectFinish = expectation(description: "")
        let expectCancel = expectation(description: "")

        let firstOperation = BlockMapOperation<Void, String> { input in
            return Result { "one" }
        }
        
        let secondOperation = BlockMapOperation<String, String> { _ in
            usleep(2 * 1000000)
            return Result { "two" }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group()
        
        firstOperation.addResultBlock { result in
            expectFinish.fulfill()
        }
        
        group1.addResultBlock { result in
            expectCancel.fulfill()
        }
        
        // Start the group
        group1.enqueue()
        
        // Wait until the first op in the group has finished (op 2 has a delay)
        wait(for: [expectFinish], timeout: 10)
        
        // Now cancel the group and children
        group1.cancel()
        
        // Wait for the group to finish
        wait(for: [expectCancel], timeout: 10)

        
        // We expect the group to be cancelled
        // Op1 to NOT be cancelled, since it finished before the cancel command
        // Op2 to be cancelled, since the cancel command came in as it was executing
        XCTAssert(group1.isFinished && group1.isCancelled)
        XCTAssert(firstOperation.isFinished && !firstOperation.isCancelled)
        XCTAssert(secondOperation.isFinished && secondOperation.isCancelled)
    }

}
