//
//  Collection+Operations.swift
//  Operation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

public extension Collection where Iterator.Element: Operation {
    
    
    /// Enqueue a collection of operations on the given queue.
    ///
    /// - Parameter queue: The queue to use. If not provided, a new one is made (optional).
    func enqueue(on queue: OperationQueue = OperationQueue()) {
        queue.addOperations(Array(self), waitUntilFinished: false)
    }
}
