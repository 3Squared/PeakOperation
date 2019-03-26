//
//  ResultTests.swift
//  ResultTests
//
//  Created by Sam Oakley on 08/12/2016.
//  Copyright © 2016 3Squared. All rights reserved.
//

import XCTest
#if os(iOS)
@testable import PeakOperation_iOS
#else
@testable import PeakOperation_macOS
#endif

class ResultTests: XCTestCase {
    
    func testInput() {
        let expect = expectation(description: "")
        
        let negatingOperation = BlockMapOperation<Bool, Bool> { input in
            do {
                let boolean = try input.get()
                return Result { return !boolean }
            } catch {
                return Result { throw error }
            }
        }
        
        negatingOperation.input = Result { true }
        
        negatingOperation.addResultBlock { output in
            do {
                let boolean = try output.get()
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
                let boolean = try previous.get()
                return Result { return !boolean }
            } catch {
                return Result { throw error }
            }
        }
        
        let stringOperation = BlockMapOperation<Bool, String> { previous in
            do {
                let boolean = try previous.get()
                return Result { return boolean.description }
            } catch {
                return Result { throw error }
            }
        }
        
        
        stringOperation.addResultBlock { result in
            do {
                let string = try result.get()
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
    
    func testCancelledOperationPassesNoInput() {
        let expect = expectation(description: "")
        
        let firstOperation = BlockMapOperation<String, String> { _ in
            return Result { "first" }
        }

        let secondOperation = BlockMapOperation<String, String> { input in
            do {
                _ = try input.get()
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
    
    func testEnqueueWithCompletion() {
        let expect = expectation(description: "")
        
        let _ = BlockResultOperation {
            return true
        }.enqueue { output in
            do {
                let boolean = try output.get()
                XCTAssertTrue(boolean)
                expect.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testPassingAResultIntoMultipleOperations() {
        let operationA = BlockMapOperation<Void, String> { _ in
            return .success("hello")
        }
        
        let operationsB = [
            BlockMapOperation<String, String> { input in
                return .success(try! input.get() + " my name is sam")
            },
            BlockMapOperation<String, String> { input in
                return .success(try! input.get() + " world")
            }
        ]
        
        let expect1 = expectation(description: "")
        operationsB[0].addResultBlock { _ in
            expect1.fulfill()
        }
        
        let expect2 = expectation(description: "")
        operationsB[1].addResultBlock { _ in
            expect2.fulfill()
        }
        
        operationA
            .passesResult(to: operationsB)
            .enqueue()
        
        waitForExpectations(timeout: 5)
        
        let output1 = try! operationsB[0].output.get()
        let output2 = try! operationsB[1].output.get()

        XCTAssertEqual(output1, "hello my name is sam")
        XCTAssertEqual(output2, "hello world")
    }

    
    func testPassingMultipleResultsIntoAnOperation() {
        let operationsA = [
            BlockMapOperation<String, String> { input in
                return .success("hello my name is sam")
            },
            BlockMapOperation<String, String> { input in
                return .success("hello world")
            }
        ]
        let operationB = CombineOperation<String>()
        
        let expect = expectation(description: "")
        
        operationsA
            .passesResults(to: operationB)
            .enqueue { _ in
                expect.fulfill()
            }
        
        waitForExpectations(timeout: 100)
        
        let output = try! operationB.output.get()
        XCTAssertEqual(output.count, 2)
        XCTAssertTrue(output.contains("hello my name is sam"))
        XCTAssertTrue(output.contains("hello world"))
    }

}

public enum TestError: Error {
    case justATest
    case alsoATest
}
