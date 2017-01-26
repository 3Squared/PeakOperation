//
//  Operation+Queue.swift
//  Operation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

public extension Operation {

    func enqueue(on queue: OperationQueue = OperationQueue()) {
        queue.addOperation(self)
    }
    
    @discardableResult
    public func then(do operation: Operation) -> Operation {
        addDependency(operation)
        return operation
    }
}
