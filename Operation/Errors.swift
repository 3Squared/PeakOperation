//
//  Errors.swift
//  THROperations
//
//  Created by Sam Oakley on 13/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation

/// Used when an operation fails
///
/// - noResult: The initial value of an operation Result, before it has been set
public enum OperationError: Error {
    case noResult
}
