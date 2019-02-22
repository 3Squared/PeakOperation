//
//  Operation+Queue.swift
//  PeakOperation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation
import PeakResult

// Extensions on `Operation` that enable chaining and result passing.
public extension Operation {

    /// The list of this operation's dependancies, and their dependencies, recursively.
    /// Includes `self`.
    internal var operationChain: [Operation] {
        return dependencies.flatMap { $0.operationChain } + [self]
    }
    
    /// Enqueue all of the operation chain, which includes the receiver and 
    /// all of the receiver dependancies, and their dependencies, recursively.
    ///
    /// - Parameter queue: The queue to use. If not provided, a new one is made (optional).
    @discardableResult
    func enqueue(on queue: OperationQueue = OperationQueue()) -> Self {
        operationChain.enqueue(on: queue)
        return self
    }
    
    /// Add the given operation as a dependancy of the receiver.
    /// The given operation will therefore be executed after self has completed.
    ///
    /// - Parameter operation: An operation to run after `self` is finished.
    /// - Returns: The dependant operation, with the dependancy added.
    @discardableResult
    public func then<O: Operation>(do operation: O) -> O {
        operation.addDependency(self)
        return operation
    }
}

extension ProducesResult where Self: Operation {
    
    /// Enqueue all of the operation chain, which includes the receiver and
    /// all of the receiver dependancies, and their dependencies, recursively.
    ///
    /// - Parameters:
    ///   - queue: The queue to use. If not provided, a new one is made (optional).
    ///   - completion: The block to be called on completion.
    /// - Returns: The operation that was queued.
    @discardableResult
    func enqueue(on queue: OperationQueue = OperationQueue(), completion: @escaping (Result<Output>) -> ()) -> Self {
        addResultBlock(block: completion)
        operationChain.enqueue(on: queue)
        return self
    }
}

public extension ConcurrentOperation {
    
    /// Enqueue all of the operation chain, which includes the receiver and
    /// all of the receiver dependancies, and their dependencies, recursively.
    ///
    /// - Parameter queue: The queue to use. If not provided, a new one is made (optional).
    /// - Returns: The progress of the operation chain's execution.
    func enqueueWithProgress(on queue: OperationQueue = OperationQueue()) -> Progress {
        enqueue(on: queue)
        return overallProgress()
    }
}

public extension Collection where Iterator.Element: Operation {
    
    /// Enqueue a collection of operations on the given queue.
    ///
    /// - Parameter queue: The queue to use. If not provided, a new one is made (optional).
    func enqueue(on queue: OperationQueue = OperationQueue()) {
        queue.addOperations(Array(self), waitUntilFinished: false)
    }
}
