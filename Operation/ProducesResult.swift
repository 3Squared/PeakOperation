//
//  ProducesResult.swift
//  THROperations
//
//  Created by Sam Oakley on 10/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation
import THRResult

public protocol ProducesResult: class {
    associatedtype Output
    var output: Result<Output> { get set }
}

public protocol ConsumesResult: class {
    associatedtype Input
    var input: Result<Input> { get set }
}

public enum ResultError: Error {
    case noResult
}

extension ProducesResult where Self: Operation {
    public func addResultBlock(block: @escaping (Result<Output>) -> Void) {
        if let existing = completionBlock {
            completionBlock = {
                existing()
                block(self.output)
            }
        }
        else {
            completionBlock = {
                block(self.output)
            }
        }
    }
}

extension ProducesResult where Self: BaseOperation {
    @discardableResult
    public func passesResult<Consumer>(to operation: Consumer) -> Consumer where Consumer: Operation, Consumer: ConsumesResult, Consumer.Input == Self.Output {
        operation.addDependency(self)
        self.didFinish = {
            if !self.isCancelled {
                operation.input = self.output
            }
        }
        return operation
    }
}

