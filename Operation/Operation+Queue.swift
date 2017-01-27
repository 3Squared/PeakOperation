//
//  Operation+Queue.swift
//  Operation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

public extension Operation {

    internal var recursiveDependencies: [Operation] {
        return dependencies.flatMap { $0.recursiveDependencies } + [self]
    }
    
    func enqueue(on queue: OperationQueue = OperationQueue()) {
        recursiveDependencies.enqueue(on: queue)
    }
    
    @discardableResult
    public func then(do operation: Operation) -> Operation {
        addDependency(operation)
        return operation
    }
}
