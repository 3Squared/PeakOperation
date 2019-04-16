//
//  Operation+Queue.swift
//  PeakOperation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

// Extensions on `Operation` that enable chaining and result passing.
extension Operation {

    /// The list of this operation's dependancies, and their dependencies, recursively.
    /// Includes `self`.
    public var operationChain: Set<Operation> {
        return Set(dependencies.flatMap { $0.operationChain } + [self])
    }
    
    /// Enqueue all of the operation chain, which includes the receiver and 
    /// all of the receiver dependancies, and their dependencies, recursively.
    ///
    /// - Parameter queue: The queue to use. If not provided, a new one is made (optional).
    @discardableResult
    public func enqueue(on queue: OperationQueue = OperationQueue()) -> Self {
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
    
    public func chainProgress() -> Progress {
        let chain = operationChain.compactMap { $0 as? ConcurrentOperation }
        let totalProgress = Progress(totalUnitCount: 100)
        let progressPerOperation = totalProgress.totalUnitCount / Int64(chain.count)
        let remainder = totalProgress.totalUnitCount - (progressPerOperation * Int64(chain.count))
        
        chain.enumerated().forEach { index, operation in
            if index < chain.count - 1 {
                totalProgress.addChild(operation.progress, withPendingUnitCount: progressPerOperation)
            } else {
                totalProgress.addChild(operation.progress, withPendingUnitCount: progressPerOperation + remainder)
            }
        }
        
        return totalProgress
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
    public func enqueue(on queue: OperationQueue = OperationQueue(), completion: @escaping (Result<Output, Error>) -> Void) -> Self {
        addResultBlock(block: completion)
        operationChain.enqueue(on: queue)
        return self
    }
}

extension ConcurrentOperation {
    
    /// Enqueue all of the operation chain, which includes the receiver and
    /// all of the receiver dependancies, and their dependencies, recursively.
    ///
    /// - Parameter queue: The queue to use. If not provided, a new one is made (optional).
    /// - Returns: The progress of the operation chain's execution.
    public func enqueueWithProgress(on queue: OperationQueue = OperationQueue()) -> Progress {
        enqueue(on: queue)
        return chainProgress()
    }
}

extension ProducesResult where Self: ConcurrentOperation {
    
    /// Enqueue all of the operation chain, which includes the receiver and
    /// all of the receiver dependancies, and their dependencies, recursively.
    ///
    /// - Parameter queue: The queue to use. If not provided, a new one is made (optional).
    /// - Returns: The progress of the operation chain's execution.
    public func enqueueWithProgress(on queue: OperationQueue = OperationQueue(), completion: @escaping (Result<Output, Error>) -> Void) -> Progress {
        addResultBlock(block: completion)
        enqueue(on: queue)
        return chainProgress()
    }
}

extension Collection where Iterator.Element: Operation {
    
    /// Enqueue a collection of operations on the given queue.
    ///
    /// - Parameter queue: The queue to use. If not provided, a new one is made (optional).
    public func enqueue(on queue: OperationQueue = OperationQueue()) {
        let chain = Set(flatMap { $0.operationChain })
        queue.addOperations(Array(chain), waitUntilFinished: false)
    }
}
