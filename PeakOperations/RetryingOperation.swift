//
//  RetryingOperation.swift
//  PeakOperations
//
//  Created by Sam Oakley on 16/11/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation
import THRResult

/// A `ConcurrentOperation` with an added `RetryStrategy`.
/// When the operation completes with an error `Result`, the `StrategyBlock` is used to determine if the operation should be attempted again.
/// This does not add a new operation, it simply restarts the original.
open class RetryingOperation<Output>: ConcurrentOperation, ProducesResult {

    /// The result produced by the operation. 
    /// This is checked, and if it is of type `failure(...)`, then the `retryStrategy` will be executed.
    public var output: Result<Output> = Result { throw ResultError.noResult }

    var failureCount = 0
    
    
    /// A `StrategyBlock` which is executed to determine whether the operation should be retried.
    /// Some default strategies are provided in `RetryStrategy`, but you may provide any block.
    public var retryStrategy: StrategyBlock = RetryStrategy.none
    
    /// :nodoc:
    open override func finish() {
        switch output {
        case .failure(_):
            failureCount += 1
            if retryStrategy(failureCount) {
                execute()
                return
            }
        default:
            break;
        }
        super.finish()
    }
}

/// Takes the number of attempts and returns a boolean indicating whether to retry.
public typealias StrategyBlock = (Int) -> Bool

/// Common retry strategies that can be used to determine if a `RetryingOperation` should retry on failure.
/// You can implement your own strategies by providing a block of type `(Int) -> Bool`.
public struct RetryStrategy {
    
    /// Do not retry.
    public static let none: StrategyBlock = { _ in return false }

    /// Repeat the given number of times. There is no delay between attempts.
    ///
    /// - Parameter times: number of times to retry.
    public static func `repeat`(times: Int)  -> StrategyBlock {
        return { attemptCount in return attemptCount <= times }
    }
}
