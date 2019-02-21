//
//  PeakOperationTests.swift
//  PeakOperationTests
//
//  Created by Sam Oakley on 08/12/2016.
//  Copyright © 2016 3Squared. All rights reserved.
//

import XCTest
import PeakResult

#if os(iOS)

@testable import PeakOperation_iOS

#else

@testable import PeakOperation_macOS

#endif

class PeakOperationTests: XCTestCase {
    
    func testInput() {
        let expect = expectation(description: "")
        
        let negatingOperation = BlockMapOperation<Bool, Bool> { input in
            do {
                let boolean = try input.resolve()
                return Result { return !boolean }
            } catch {
                return Result { throw error }
            }
        }
        
        negatingOperation.input = Result { true }
        
        negatingOperation.addResultBlock { output in
            do {
                let boolean = try output.resolve()
                XCTAssertFalse(boolean)
                expect.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        negatingOperation.enqueue()
        
        waitForExpectations(timeout: 1)
    }
    
    func testDependancies() {
        let expectFirst = expectation(description: "")
        let expectSecond = expectation(description: "")

        let firstOperation = BlockResultOperation {
            return true
        }
        
        let secondOperation = BlockResultOperation {
            return true
        }
        
        firstOperation.completionBlock = {
            expectFirst.fulfill()
        }
        
        secondOperation.completionBlock = {
            expectSecond.fulfill()
        }
        
        firstOperation
            .then(do: secondOperation)
            .enqueue()
        
        waitForExpectations(timeout: 10)
    }
    
    func testInjectionPassing() {
        let expect = expectation(description: "")
        
        let trueOperation = BlockResultOperation {
            return true
        }
        
        let negatingOperation = BlockMapOperation<Bool, Bool> { previous in
            do {
                let boolean = try previous.resolve()
                return Result { return !boolean }
            } catch {
                return Result { throw error }
            }
        }
        
        let stringOperation = BlockMapOperation<Bool, String> { previous in
            do {
                let boolean = try previous.resolve()
                return Result { return boolean.description }
            } catch {
                return Result { throw error }
            }
        }
        
        
        stringOperation.addResultBlock { result in
            do {
                let string = try result.resolve()
                XCTAssertEqual(string, "false")
                expect.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        trueOperation
            .passesResult(to: negatingOperation)
            .passesResult(to: stringOperation)
            .enqueue()
        
        waitForExpectations(timeout: 10)
    }
    
    func testSingleOperationRecursiveDependencies() {
        let op1 = BlockMapOperation<Bool, Bool> { _ in
            return Result { return false }
        }
        XCTAssertEqual(op1.operationChain, [op1])
    }
    
    func testManyOperationsRecursiveDependencies() {
        let op1 = BlockMapOperation<Bool, Bool> { _ in
            return Result { return false }
        }
        
        let op2 = BlockMapOperation<Bool, Bool> { _ in
            return Result { return false }
        }
        
        let op3 = BlockMapOperation<Bool, Bool> { _ in
            return Result { return false }
        }
        
        op1.passesResult(to: op2).passesResult(to: op3)
        
        XCTAssertEqual(op3.operationChain, [op1, op2, op3])
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

    
    func testCancelledOperationPassesNoInput() {
        let expect = expectation(description: "")
        
        let firstOperation = BlockMapOperation<String, String> { _ in
            return Result { "first" }
        }

        let secondOperation = BlockMapOperation<String, String> { input in
            do {
                _ = try input.resolve()
                XCTFail()
            } catch {
                expect.fulfill()
            }
            return Result { throw TestError.justATest }
        }
        
        firstOperation
            .passesResult(to: secondOperation)
            .enqueue()
        
        
        firstOperation.cancel()
        
        waitForExpectations(timeout: 10)
    }
    
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

    func testEnqueueWithCompletion() {
        let expect = expectation(description: "")
        
        let _ = BlockResultOperation {
            return true
        }.enqueue { output in
            do {
                let boolean = try output.resolve()
                XCTAssertTrue(boolean)
                expect.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    
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

public enum TestError: Error {
    case justATest
    case alsoATest
}

open class TestRetryOperation: RetryingOperation<AnyObject> {
    open override func execute() {
        output = Result { throw TestError.justATest }
        finish()
    }
}

open class TestMapValueOperation: MapOperation<Bool, Bool> {
    open override func map(input: Bool) -> Result<Bool> {
        return .success(!input)
    }
}

open class TestMapResultOperation: MapOperation<Bool, Bool> {
    open override func map(input: Result<Bool>) -> Result<Bool> {
        switch input {
        case .success(let value):
            return .success(!value)
        case .failure(_):
            return .failure(TestError.alsoATest)
        }
    }
}
