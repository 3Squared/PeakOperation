//
//  BaseOperation.swift
//  Operation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

open class BaseOperation: Operation {
    internal var willStart: () -> () = { }
    
    open override func start() {
        willStart()
        super.start()
    }
}
