//
//  Result.swift
//  Adapted from http://alisoftware.github.io/swift/async/error/2016/02/06/async-errors/
//
//  Created by Sam Oakley on 28/11/2016.
//  Copyright © 2016 3Squared. All rights reserved.
//
import Foundation


/// An enum that contains a result. The result can be of type T, or it may be an error.
///
/// - success: If the result is successful, will contain a non-optional value of type T
/// - failure: If the result is a failure, will contain an Error
public enum Result<T> {
    case success(T)
    case failure(Error)
    
    
    /// Call to convert the enum into either the value T or rethrow the error.
    /// Use if you want to deal with the result using the do-catch pattern.
    ///
    /// - throws: The error that caused the failure
    ///
    /// - returns: The successful result of type T
    public func resolve() throws -> T {
        switch self {
        case Result.success(let value): return value
        case Result.failure(let error): throw error
        }
    }
    
    
    /// Construct a Result using a block that can either return T or throw.
    /// .Success if the expression returns a value or a .Failure if it throws
    ///
    /// - parameter throwingExpr: A closure that returns a value of type T or throws
    ///
    /// - returns: A Result
    public init( _ throwingExpr: (Void) throws -> T) {
        do {
            let value = try throwingExpr()
            self = Result.success(value)
        } catch {
            self = Result.failure(error)
        }
    }
}
