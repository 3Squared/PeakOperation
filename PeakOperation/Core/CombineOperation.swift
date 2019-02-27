//
//  CombineOperation.swift
//  PeakOperation-iOS
//
//  Created by Sam Oakley on 27/02/2019.
//  Copyright © 2019 3Squared. All rights reserved.
//

import Foundation
import PeakResult


/// Take an array of Results and combine them into a Result holding an array.
/// If any of the elements of the input are errors, then the output will be an error.
open class CombineOperation<Input>: ConcurrentOperation, ConsumesMultipleResults, ProducesResult {

    public var input: [Result<Input>] = []
    public var output: Result<[Input]> = .failure(ResultError.noResult)
    
    public init(input: [Result<Input>]? = nil) {
        super.init()
        if let input = input {
            self.input = input
        }
    }

    open override func execute() {
        output = combine(input: input)
        finish()
    }
    
    open func combine(input: [Result<Input>]) -> Result<Output> {
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
            let inputs = input.map { try! $0.resolve() }
            return .success(inputs)
        }
    }
    
}

public enum CombineOperationError: Error {
    case errors([Error])
}
