//
//  GroupChainOperation.swift
//  PeakOperation
//
//  Created by Sam Oakley on 04/12/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

/// An operation which takes an operation and its dependants and executes them on an internal queue.
///
/// The result of the final operation in the chain is retained and it is inspected in order
/// that this operation can produce a result.
/// If any operation in the group fails, the overall group operation will have a failure result.
/// If it succeeds, it will be a successful result but contain no object.
@available(iOS 9, macOS 10.11, *)
open class GroupChainOperation: ConcurrentOperation, ProducesResult, ConsumesResult {
    
    public var output: Result<Void, Error> = Result { throw ResultError.noResult }
    public var input: Result<Void, Error> = Result { }
    
    fileprivate let operation: Operation
    
    /// Create a new `GroupChainOperation`.
    ///
    /// - Parameter operation: A operation that produces a result. Its dependants will also be run.
    public init<L>(with operation: L, collateProgress: Bool = false) where L: ProducesResult, L: Operation {
        self.operation = operation
        super.init()
        
        managesOwnProgress = collateProgress
        
        if (collateProgress) {
            progress = operation.chainProgress()
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
            try input.get()
            operation.enqueue(on: internalQueue)
        } catch {
            output = Result { throw error }
            finish()
        }
    }
}

@available(iOS 9, macOS 10.11, *)
extension ProducesResult where Self: ConcurrentOperation {
    
    /// Add the operation and its chain to a group.
    ///
    /// - Returns: A GroupChainOperation containing the operation and its chain.
    public func group(collateProgress: Bool = false) -> GroupChainOperation {
        return GroupChainOperation(with: self, collateProgress: collateProgress)
    }
}
