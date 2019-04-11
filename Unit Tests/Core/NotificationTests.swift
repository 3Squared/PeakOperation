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

class NotificationTests: XCTestCase {
    
    func testWillStartNotificationIsSent() {
        let queue = OperationQueue()
        let operation = BlockResultOperation { return "Hello" }
        operation.enqueue(on: queue)
        
        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default)
        
        waitForExpectations(timeout: 10)
    }

    func testWillFinishNotificationIsSent() {
        let queue = OperationQueue()
        let operation = BlockResultOperation { return "Hello" }
        operation.enqueue(on: queue)
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default)
        
        waitForExpectations(timeout: 10)
    }

    func testNotificationContainsQueueName() {
        let queue = OperationQueue()
        queue.name = "NotificationTests.Queue"
        
        let operation = BlockResultOperation { return "Hello" }
        operation.enqueue(on: queue)
        
        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default) { notification in
            let currentQueueName = notification.userInfo?["queue"] as! String
            XCTAssertEqual(currentQueueName, queue.name)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default) { notification in
            let currentQueueName = notification.userInfo?["queue"] as! String
            XCTAssertEqual(currentQueueName, queue.name)
            return true
        }
        
        waitForExpectations(timeout: 10)
    }

    
    func testCustomOperationLabelIsSentInNotification() {
        let operation = BlockResultOperation { return "Hello" }
        operation.label = "Doing some work..."
        operation.enqueue()
        
        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default) { notification in
            let operationLabel = notification.userInfo?["label"] as! String
            XCTAssertEqual(operationLabel, operation.label)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default) { notification in
            let operationLabel = notification.userInfo?["label"] as! String
            XCTAssertEqual(operationLabel, operation.label)
            return true
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testOperationIsSentInNotification() {
        let operation = BlockResultOperation { return "Hello" }
        operation.label = "Doing some work..."
        operation.enqueue()
        
        expectation(forNotification: ConcurrentOperation.operationWillStart, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertEqual(object, operation)
            return true
        }
        
        expectation(forNotification: ConcurrentOperation.operationWillFinish, object: nil, notificationCenter: .default) { notification in
            let object = notification.object as! ConcurrentOperation
            XCTAssertEqual(object, operation)
            return true
        }
        
        waitForExpectations(timeout: 10)
    }

}
