//
//  ProgressTests.swift
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

class ProgressTests: XCTestCase {

    func testOperationProgress() {
        
        let operation1 = BlockResultOperation {
            return true
        }
        
        let operation2 = BlockResultOperation {
            return true
        }
        
        let operation3 = BlockMapOperation<String, String> { input in
            return Result { throw TestError.justATest }
        }
        
        let operation4 = BlockResultOperation {
            return true
        }
        
        operation1
            .then(do: operation2)
            .then(do: operation3)
            .then(do: operation4)
        
        
        let progress = operation4.overallProgress()
        
        keyValueObservingExpectation(for: progress, keyPath: "completedUnitCount") {  observedObject, change in
            print("Change: \(change)")
            return progress.completedUnitCount >= progress.totalUnitCount
        }
        
        operation4.enqueue()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(progress.fractionCompleted, 1)
        print("Total Progress: \(progress.localizedAdditionalDescription!)")
    }
    
    func testSubclassWithDetailedOperationProgress() {
        
        let operation1 = BlockResultOperation {
            return true
        }
        
        let operation2 = BlockResultOperation {
            return true
        }
        
        operation1.estimatedExecutionSeconds = 1
        operation2.estimatedExecutionSeconds = 10
        
        operation1.then(do: operation2)
        
        let progress = operation2.overallProgress()
        
        keyValueObservingExpectation(for: progress, keyPath: "completedUnitCount") {  observedObject, change in
            print("Change: \(progress.localizedDescription!)")
            return progress.completedUnitCount >= progress.totalUnitCount
        }
        
        operation2.enqueue()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(progress.fractionCompleted, 1)
        XCTAssertEqual(progress.totalUnitCount, 11)
        print("Total Progress: \(progress.localizedAdditionalDescription!)")
    }
    
    func testGroupOperationProgress() {
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
        
        let progress = group1.enqueueWithProgress()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(progress.fractionCompleted, 1)
        XCTAssertEqual(progress.totalUnitCount, 1)
        print("Total Progress: \(progress.localizedAdditionalDescription!)")
    }
    
    func testGroupOperationCollatingProgress() {
        let expect = expectation(description: "")
        
        let firstOperation = BlockResultOperation {
            return "Hello"
        }
        
        let secondOperation = BlockMapOperation<String, String> { input in
            return Result { try "\(input.resolve()) World!" }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group(collateProgress: true)
        
        group1.addResultBlock { result in
            do {
                let _ = try result.resolve()
                expect.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        let progress = group1.enqueueWithProgress()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(progress.fractionCompleted, 1)
        XCTAssertEqual(progress.totalUnitCount, 2)
        print("Total Progress: \(progress.localizedAdditionalDescription!)")
    }
}
