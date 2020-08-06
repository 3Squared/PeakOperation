//
//  CombineOperation.swift
//  PeakOperation
//
//  Created by Sam Oakley on 27/02/2019.
//  Copyright © 2019 3Squared. All rights reserved.
//

import Foundation

/// Take an array of Results and combine them into a Result holding an array.
/// If any of the elements of the input are errors, then the output will be an error.
open class CombineOperation<Input>: ConcurrentOperation, ConsumesMultipleResults, ProducesResult {

    public var input: [Result<Input, Error>] = []
    public var output: Result<[Input], Error> = .failure(ResultError.noResult)
    
    public init(input: [Result<Input, Error>]? = nil) {
        super.init()
        if let input = input {
            self.input = input
        }
    }

    open override func execute() {
        output = combine(input: input)
        finish()
    }
    
    open func combine(input: [Result<Input, Error>]) -> Result<Output, Error> {
        guard input.count > 0 else { return .failure(ResultError.noResult) }
        
        let errors: [Error] = input.compactMap {
            switch $0 {
            case .failure(let error): return error
            default: return nil
            }
        }
        
        if errors.count > 0 {
            return .failure(CombineOperationError.errors(errors))
        } else {
            let inputs = input.map { try! $0.get() }
            return .success(inputs)
        }
    }
    
}

public enum CombineOperationError: Error {
    case errors([Error])
}
