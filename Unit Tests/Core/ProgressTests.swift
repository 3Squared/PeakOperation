//
//  ProgressTests.swift
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
        
        
        let progress = operation4.chainProgress()
        
        keyValueObservingExpectation(for: progress, keyPath: "completedUnitCount") {  observedObject, change in
            print("Change: \(change)")
            return progress.completedUnitCount >= progress.totalUnitCount
        }
        
        operation4.enqueue()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(progress.fractionCompleted, 1)
    }
    
    func testGroupOperationProgress() {
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
        
        let progress = group1.enqueueWithProgress()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(progress.fractionCompleted, 1)
    }
    
    func testGroupOperationCollatingProgress() {
        let expect = expectation(description: "")
        
        let firstOperation = BlockResultOperation {
            return "Hello"
        }
        
        let secondOperation = BlockMapOperation<String, String> { input in
            return Result { try "\(input.get()) World!" }
        }
        
        let group1 = firstOperation
            .passesResult(to: secondOperation)
            .group(collateProgress: true)
        
        group1.addResultBlock { result in
            do {
                let _ = try result.get()
                expect.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        let progress = group1.enqueueWithProgress()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(progress.fractionCompleted, 1)
    }
    
    func testNestedGroupOperationsCollatingProgress() {
        let a1 = BlockResultOperation {
            return 1
        }
        
        let a2 = BlockResultOperation {
            return 2
        }

        let a3 = BlockResultOperation {
            return 3
        }

        let b1 = BlockResultOperation {
            return 1
        }
        
        let b2 = BlockResultOperation {
            return 2
        }
        
        let b3 = BlockResultOperation {
            return 3
        }

        let a = a1.then(do: a2).then(do: a3).group(collateProgress: true)
        
        let b = b1.then(do: b2).then(do: b3).group(collateProgress: true)

        
        let superGroup = a.then(do: b).group(collateProgress: true)
        
        let progress = superGroup.enqueueWithProgress()

        keyValueObservingExpectation(for: progress, keyPath: "fractionCompleted") {  observedObject, change in
            print("Change: \(progress.localizedDescription!)")
            return progress.completedUnitCount == progress.totalUnitCount
        }

        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(progress.fractionCompleted, 1)
    }

}
