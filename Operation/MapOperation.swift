//
//  MapOperation.swift
//  THROperations
//
//  Created by Sam Oakley on 14/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation
import THRResult

open class MapOperation<Input, Output>: BaseOperation, ProducesResult, ConsumesResult {
    
    public var output: Result<Output> = Result { throw ResultError.noResult }
    public var input: Result<Input> = Result { throw ResultError.noResult }

    let block: (Result<Input>) -> (Result<Output>)
    
    public init(_ block: @escaping (Result<Input>) -> (Result<Output>)) {
        self.block = block
    }
    
    open override func run() {
        self.output = self.block(input)
        finish()
    }
}
