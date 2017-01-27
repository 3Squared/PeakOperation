//
//  Operation+Queue.swift
//  Operation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

public extension Operation {

    internal var operationChain: [Operation] {
        return dependencies.flatMap { $0.operationChain } + [self]
    }
    
    func enqueue(on queue: OperationQueue = OperationQueue()) {
        operationChain.enqueue(on: queue)
    }
    
    @discardableResult
    public func then(do operation: Operation) -> Operation {
        addDependency(operation)
        return operation
    }
}
