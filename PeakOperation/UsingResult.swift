//
//  UsingResult.swift
//  PeakOperation
//
//  Created by Sam Oakley on 10/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation
import PeakResult

/// Implement this protocol to indicate that the object will produce a `Result` as output.
public protocol ProducesResult: class {
    associatedtype Output
    
    /// The `Result` that will be produced as output.
    var output: Result<Output> { get set }
}

/// Implement this protocol to indicate that the object can receive a `Result` as input.
public protocol ConsumesResult: class {
    associatedtype Input
    
    /// The `Result` to use as input.
    var input: Result<Input> { get set }
}

/// Built-in `Error`s for use as failure states for a `ProducesResult` Operation.
public enum ResultError: Error {
    /// The initial value of an operation's `Result`, before it has been set.
    case noResult
}

extension ProducesResult where Self: Operation {
    
    /// Add a block to be called on the completion of an `Operation` that produces a result, with the `Result` as an argument.
    /// This is called at the same time and in the same manner as `completionBlock`.
    /// Multiple result blocks can be added to a single `Operation`.
    ///
    /// - Parameter block: The block to be called on completion.
    public func addResultBlock(block: @escaping (Result<Output>) -> Void) {
        if let existing = completionBlock {
            completionBlock = { [weak self] in
                guard let strongSelf = self else { return }
                existing()
                block(strongSelf.output)
            }
        }
        else {
            completionBlock = { [weak self] in
                guard let strongSelf = self else { return }
                block(strongSelf.output)
            }
        }
    }
}

extension ProducesResult where Self: ConcurrentOperation {
    
    /// Use to chain multiple operations together, passing the output result of one as the input of the next.
    /// Only useable if the output and input types match. Consider using a `MapOperation` if they do not.
    ///
    /// This is only available on `ConcurrentOperation`s because of the need for a `willFinish` notification.
    ///
    /// - Parameter operation: The operation to pass the receiver's `Result` to.
    /// - Returns: The dependant operation, with the dependancy added.
    @discardableResult
    public func passesResult<Consumer>(to operation: Consumer) -> Consumer where Consumer: Operation, Consumer: ConsumesResult, Consumer.Input == Self.Output {
        operation.addDependency(self)
        willFinish = { [weak self, unowned operation] in
            guard let strongSelf = self else { return }
            if !strongSelf.isCancelled {
                operation.input = strongSelf.output
            }
        }
        return operation
    }
}
