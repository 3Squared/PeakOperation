//
//  BaseOperation.swift
//  THROperations
//
//  Created by Sam Oakley on 10/10/2016.
//  Copyright © 2016 Sam Oakley. All rights reserved.
//

import Foundation

open class BaseOperation: Operation {
    internal var willStart: () -> () = { }
    internal var willFinish: () -> () = { }

    var _executing = false
    var _finished = false
    
    open func run() {
        fatalError("\(self) must override `run()`.")
    }
    
    override open func start() {
        super.start()
        if isCancelled {
            notifyChanges(#keyPath(Operation.isFinished)) {
                _finished = true
            }
            return
        }
        
        willStart()
        notifyChanges(#keyPath(Operation.isExecuting)) {
            _executing = true
            run()
        }
    }

    public func finish()  {
        willFinish()
        notifyChanges(#keyPath(Operation.isFinished), #keyPath(Operation.isExecuting)) {
            _executing = false
            _finished = true
        }
    }
    
    private func notifyChanges(_ keys: String..., changes: (Void) -> (Void)) {
        for key in keys {
            willChangeValue(forKey: key)
        }
        changes()
        for key in keys {
            didChangeValue(forKey: key)
        }
    }
    
    override open var isExecuting: Bool {
        return _executing
    }
    
    override open var isFinished: Bool {
        return _finished
    }
    
    override open var isConcurrent: Bool {
        return true
    }
}
