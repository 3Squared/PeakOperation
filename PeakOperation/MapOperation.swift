//
//  MapOperation.swift
//  PeakOperation
//
//  Created by Sam Oakley on 14/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation
import PeakResult

/// An operation which takes an Input and maps it to an Output.
///
/// When chaining operations, you may wish to pass the result of one to another, but the types do not match.
/// By inserting a MapOperation between them, you can perform a mapping of the Output type to the Input type.
///
/// `ProducesStringOperation -> MapOperation<String, Integer> -> ConsumesIntegerOperation`
open class MapOperation<Input, Output>: ConcurrentOperation, ProducesResult, ConsumesResult {
    
    /// The result to be mapped.
    public var input: Result<Input> = Result { throw ResultError.noResult }
    
    /// The mapped result.
    public var output: Result<Output> = Result { throw ResultError.noResult }
    
    let block: (Result<Input>) -> (Result<Output>)
    
    /// Create a new `MapOperation`.
    ///
    /// - Parameter block: A block which takes a Result of type `Input` and maps it to one with type `Output`.
    public init(_ block: @escaping (Result<Input>) -> (Result<Output>)) {
        self.block = block
    }
    
    /// :nodoc:
    open override func execute() {
        self.output = self.block(input)
        finish()
    }
}
