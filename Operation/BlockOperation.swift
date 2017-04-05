//
//  BaseOperation.swift
//  THROperations
//
//  Created by Sam Oakley on 14/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation
import THRResult

open class BlockOperation<Output>: ConcurrentOperation, ProducesResult {
    public var output: Result<Output> = Result { throw ResultError.noResult }
    let block: () -> (Result<Output>)
    
    public init(_ block: @escaping () -> (Output)) {
        self.block = {
            return Result { return block() }
        }
    }
    
    public init(_ block: @escaping () -> (Result<Output>)) {
        self.block = block
    }
    
    open override func execute() {
        self.output = self.block()
        finish()
    }
}
