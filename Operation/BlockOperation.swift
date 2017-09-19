//
//  BaseOperation.swift
//  THROperations
//
//  Created by Sam Oakley on 14/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation
import THRResult


/// Wrap a given block as an `Operation`.
///
/// Executes the block in `execute()` then immediately finishes the operation.
/// The result of the operation will be set to the result of the block.
open class BlockOperation<Output>: ConcurrentOperation, ProducesResult {
    
    /// The result produced by executing the block.
    public var output: Result<Output> = Result { throw ResultError.noResult }
    
    let block: () -> (Result<Output>)
    
    
    /// Create a new `BlockOperation`.
    /// The return value of the block will be wrapped and set as the operation's `Result`.
    ///
    /// - Parameter block: A block with a return value.
    public init(_ block: @escaping () -> (Output)) {
        self.block = {
            return Result { return block() }
        }
    }
    
    
    /// Create a new `BlockOperation`. 
    /// The `Result` of the block will be set as the operation's `Result`.
    ///
    /// - Parameter block: A block that returns a `Result`.
    public init(_ block: @escaping () -> (Result<Output>)) {
        self.block = block
    }
    
    /// :nodoc:
    open override func execute() {
        self.output = self.block()
        finish()
    }
}
