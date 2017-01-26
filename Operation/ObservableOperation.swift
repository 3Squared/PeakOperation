//
//  ObservableOperation.swift
//  Operation
//
//  Created by Sam Oakley on 26/01/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

import Foundation

open class ObservableOperation: Operation {
    open var willStart: () -> () = { }

    open override func start() {
        willStart()
        super.start()
    }
}
