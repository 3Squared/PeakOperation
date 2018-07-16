//
//  Operation+Queue.swift
//  PeakOperation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

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
    func enqueue(on queue: OperationQueue = OperationQueue()) {
        operationChain.enqueue(on: queue)
    }
    
    /// Add the given operation as a dependancy of the receiver.
    /// The given operation will therefore be executed after self has completed.
    ///
    /// - Parameter operation: An operation to run after `self` is finished.
    /// - Returns: The dependant operation, with the dependancy added.
    @discardableResult
    public func then(do operation: Operation) -> Operation {
        operation.addDependency(self)
        return operation
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
