//
//  GroupChainOperation.swift
//  PeakOperation
//
//  Created by Sam Oakley on 04/12/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation
import PeakResult

/// An operation which takes an operation and its dependants and executes them on an internal queue.
///
/// The result of the final operation in the chain is retained and it is inspected in order
/// that this operation can produce a result.
/// If any operation in the group fails, the overall group operation will have a failure result.
/// If it succeeds, it will be a successful result but contain no object.
open class GroupChainOperation: ConcurrentOperation, ProducesResult, ConsumesResult {
    
    public var output: Result<Void> = Result { throw ResultError.noResult }
    public var input: Result<Void> = Result { }
    
    fileprivate lazy var internalQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "GroupOperation.InternalQueue"
        return queue
    }()

    fileprivate let operation: Operation
    
    /// Create a new `GroupChainOperation`.
    ///
    /// - Parameter operation: A operation that produces a result. Its dependants will also be run.
    public init<L>(with operation: L) where L: ProducesResult, L: Operation {
        self.operation = operation
        super.init()
        
        managesOwnProgress = true
        progress = Progress(totalUnitCount: 0)
        estimatedExecutionSeconds = 0
        
        operation.operationChain.compactMap { $0 as? ConcurrentOperation }.forEach { operation in
            let operationProgress = operation.progress
            let estimatedTime = operation.estimatedExecutionSeconds
            estimatedExecutionSeconds += estimatedTime
            progress.addChild(operationProgress, withPendingUnitCount: estimatedTime)
            progress.totalUnitCount += estimatedTime
        }
        
        operation.addResultBlock { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                strongSelf.output = Result { }
            case .failure(let error):
                strongSelf.output = Result { throw error }
            }
            strongSelf.finish()
        }
    }
    
    open override func execute() {
        do {
            try input.resolve()
            operation.enqueue(on: internalQueue)
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}


extension ProducesResult where Self: ConcurrentOperation {
    
    /// Add the operation and its chain to a group.
    ///
    /// - Returns: A GroupChainOperation containing the operation and its chain.
    public func group() -> GroupChainOperation {
        return GroupChainOperation(with: self)
    }
}
