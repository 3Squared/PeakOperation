//
//  RetryTests.swift
//  PeakOperation-iOSTests
//
//  Created by Sam Oakley on 27/02/2019.
//  Copyright © 2019 3Squared. All rights reserved.
//

import XCTest
@testable import PeakOperation

class NotificationTests: XCTestCase {
    
    func testWillStartNotificationIsSent() {
        let queue = OperationQueue()
        let operation = BlockResultOperation { return "Hello" }
        
        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default)
        
        operation.enqueue(on: queue)
        
        waitForExpectations(timeout: 10)
    }
    
    func testDidStartNotificationIsSent() {
        let queue = OperationQueue()
        let operation = BlockResultOperation { return "Hello" }
        
        expectation(forNotification: ConcurrentOperation.operationDidStart, object: nil, notificationCenter: .default)
        
        operation.enqueue(on: queue)
        
        waitForExpectations(timeout: 10)
    }

    func testWillFinishNotificationIsSent() {
        let queue = OperationQueue()
        let operation = BlockResultOperation { return "Hello" }
        operation.enqueue(on: queue)
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default)
        
        waitForExpectations(timeout: 10)
    }
    
    func testDidFinishNotificationIsSent() {
        let queue = OperationQueue()
        let operation = BlockResultOperation { return "Hello" }
        
        expectation(forNotification: ConcurrentOperation.operationDidFinish, object: nil, notificationCenter: .default)
        
        operation.enqueue(on: queue)
        
        waitForExpectations(timeout: 10)
    }

    func testNotificationContainsQueueName() {
        let queue = OperationQueue()
        queue.name = "NotificationTests.Queue"
        
        let operation = BlockResultOperation { return "Hello" }
        
        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default) { notification in
            let currentQueueName = notification.userInfo?["queue"] as! String
            XCTAssertEqual(currentQueueName, queue.name)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationDidStart, object: nil, notificationCenter: .default) { notification in
            let currentQueueName = notification.userInfo?["queue"] as! String
            XCTAssertEqual(currentQueueName, queue.name)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default) { notification in
            let currentQueueName = notification.userInfo?["queue"] as! String
            XCTAssertEqual(currentQueueName, queue.name)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationDidFinish, object: nil, notificationCenter: .default) { notification in
            let currentQueueName = notification.userInfo?["queue"] as! String
            XCTAssertEqual(currentQueueName, queue.name)
            return true
        }
        
        operation.enqueue(on: queue)
        
        waitForExpectations(timeout: 10)
    }

    
    func testCustomOperationLabelIsSentInNotification() {
        let operation = BlockResultOperation { return "Hello" }
        operation.name = "Doing some work..."

        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default) { notification in
            let operationLabel = notification.userInfo?["name"] as! String
            XCTAssertEqual(operationLabel, operation.name)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationDidStart, object: nil, notificationCenter: .default) { notification in
            let operationLabel = notification.userInfo?["name"] as! String
            XCTAssertEqual(operationLabel, operation.name)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default) { notification in
            let operationLabel = notification.userInfo?["name"] as! String
            XCTAssertEqual(operationLabel, operation.name)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationDidFinish, object: nil, notificationCenter: .default) { notification in
            let operationLabel = notification.userInfo?["name"] as! String
            XCTAssertEqual(operationLabel, operation.name)
            return true
        }
        
        operation.enqueue()
        
        waitForExpectations(timeout: 10)
    }
    
    func testOperationIsSentInNotification() {
        let operation = BlockResultOperation { return "Hello" }
        operation.name = "Doing some work..."
        
        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertEqual(object, operation)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationDidStart, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertEqual(object, operation)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertEqual(object, operation)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationDidFinish, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertEqual(object, operation)
            return true
        }
        
        operation.enqueue()
        
        waitForExpectations(timeout: 10)
    }

    func testOperationStartDateFinishDateFromNotifications() {
        let operation = BlockResultOperation { return "Hello" }
        operation.name = "Doing some work..."
        
        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertNil(object.startDate)
            XCTAssertNil(object.finishDate)
            XCTAssertEqual(operation.executionTime, 0)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationDidStart, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertNotNil(object.startDate)
            XCTAssertNil(object.finishDate)
            XCTAssertGreaterThan(operation.executionTime, 0)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertNotNil(object.startDate)
            XCTAssertNil(object.finishDate)
            XCTAssertGreaterThan(operation.executionTime, 0)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationDidFinish, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertNotNil(object.startDate)
            XCTAssertNotNil(object.finishDate)
            XCTAssertEqual(operation.executionTime, operation.finishDate!.timeIntervalSince(operation.startDate!))
            return true
        }
        
        operation.enqueue()
        
        waitForExpectations(timeout: 10)
    }
    
    func testOperationStartDateFinishDateFromBlocks() {
        let operation = BlockResultOperation { return "Hello" }
        operation.name = "Doing some work..."
        
        let expect = expectation(description: "")
        expect.expectedFulfillmentCount = 4
        
        operation.addWillStartBlock {
            XCTAssertNil(operation.startDate)
            XCTAssertNil(operation.finishDate)
            XCTAssertEqual(operation.executionTime, 0)
            expect.fulfill()
        }
        
        operation.addDidStartBlock {
            XCTAssertNotNil(operation.startDate)
            XCTAssertNil(operation.finishDate)
            XCTAssertGreaterThan(operation.executionTime, 0)
            expect.fulfill()
        }
        
        operation.addWillFinishBlock {
            XCTAssertNotNil(operation.startDate)
            XCTAssertNil(operation.finishDate)
            XCTAssertGreaterThan(operation.executionTime, 0)
            expect.fulfill()
        }
        
        operation.addDidFinishBlock {
            XCTAssertNotNil(operation.startDate)
            XCTAssertNotNil(operation.finishDate)
            XCTAssertEqual(operation.executionTime, operation.finishDate!.timeIntervalSince(operation.startDate!))
            expect.fulfill()
        }
        
        operation.enqueue()
        
        waitForExpectations(timeout: 10)
    }
    
    func testOperationHasNiceDescription() {
        let operation = BlockResultOperation { return "Hello" }
        operation.name = "Doing some work..."

        let description = operation.description
        
        XCTAssertEqual(description, "BlockResultOperation<String>(name: 'Doing some work...', state: 0)")
    }
}
