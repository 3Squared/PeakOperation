//
//  MapOperation.swift
//  PeakOperation
//
//  Created by Sam Oakley on 14/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation

/// An operation which takes an Input and maps it to an Output.
///
/// When chaining operations, you may wish to pass the result of one to another, but the types do not match.
/// By inserting a MapOperation between them, you can perform a mapping of the Output type to the Input type.
///
/// `ProducesStringOperation -> MapOperation<String, Integer> -> ConsumesIntegerOperation`
open class MapOperation<Input, Output>: ConcurrentOperation, ConsumesResult, ProducesResult {
    
    /// The result to be mapped.
    public var input: Result<Input, Error> = Result { throw ResultError.noResult }
    
    /// The mapped result.
    public var output: Result<Output, Error> = Result { throw ResultError.noResult }
    
    /// Create a new `MapOperation`.
    ///
    /// - Parameter block: An optional input value to be mapped.
    public init(input: Input? = nil) {
        super.init()
        if let input = input {
            self.input = .success(input)
        }
    }
    
    open override func execute() {
        output = self.map(input: input)
        finish()
    }
    
    /// Convert any input into a new output Result.
    ///
    /// - Parameter input:
    /// - Returns: A converted output Result.
    open func map(input: Result<Input, Error>) -> Result<Output, Error> {
        switch input {
        case .success(let value):
            return self.map(input: value)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Convert a `success` input into a new output Result.
    ///
    /// - Parameter input:
    /// - Returns: A converted output Result.
    open func map(input: Input) -> Result<Output, Error> {
        fatalError("Subclasses must implement `map(Input)` or `map(Result<Input>)`.")
    }
}

/// An operation which takes an Input and maps it to an Output.
///
/// When chaining operations, you may wish to pass the result of one to another, but the types do not match.
/// By inserting a MapOperation between them, you can perform a mapping of the Output type to the Input type.
///
/// `ProducesStringOperation -> MapOperation<String, Integer> -> ConsumesIntegerOperation`
open class BlockMapOperation<Input, Output>: MapOperation<Input, Output> {
    
    let block: (Result<Input, Error>) -> (Result<Output, Error>)
    
    /// Create a new `MapOperation`.
    ///
    /// - Parameter block: A block which takes a Result of type `Input` and maps it to one with type `Output`.
    public init(_ block: @escaping (Result<Input, Error>) -> (Result<Output, Error>)) {
        self.block = block
        super.init()
    }
    
    open override func map(input: Result<Input, Error>) -> Result<Output, Error> {
        return block(input)
    }
}
