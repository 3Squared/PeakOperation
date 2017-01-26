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

extension ConsumesResult where Self: ObservableOperation {
    @discardableResult
    public func dependsOnResult<Output>(of operation: Output) -> Output where Output: Operation, Output: ProducesResult, Output.Output == Self.Input {
        addDependency(operation)
        willStart = {
            self.input = operation.output
        }
        return operation
    }
}


extension ProducesResult where Self: Operation {
    @discardableResult
    public func passesResult<Consumer>(to operation: Consumer) -> Consumer where Consumer: ObservableOperation, Consumer: ConsumesResult, Consumer.Input == Self.Output {
        operation.addDependency(self)
        operation.willStart = {
            operation.input = self.output
        }
        return operation
    }
}
