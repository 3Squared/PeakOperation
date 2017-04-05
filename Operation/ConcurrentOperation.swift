//
//  ConcurrentOperation.swift
//  Operation
//
//  Created by David Yates on 05/04/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

// Adapted from: https://gist.github.com/calebd/93fa347397cec5f88233

@objc
fileprivate enum OperationState: Int {
    case ready
    case executing
    case finished
}

open class ConcurrentOperation: Operation {
    internal var willStart: () -> () = { }
    internal var willFinish: () -> () = { }
    
    fileprivate let stateQueue = DispatchQueue(label: "THROperations.ConcurrentOperation.StateQueue", attributes: .concurrent)
    fileprivate var rawState = OperationState.ready
    
    @objc
    fileprivate dynamic var state: OperationState {
        get {
            return stateQueue.sync(execute: { rawState })
        }
        set {
            willChangeValue(forKey: "state")
            stateQueue.sync (
                flags: .barrier,
                execute: { rawState = newValue }
            )
            didChangeValue(forKey: "state")
        }
    }
    
    // MARK: - NSObject
    
    @objc
    fileprivate dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state"]
    }
    
    @objc
    fileprivate dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }
    
    @objc
    fileprivate dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }
    
    // MARK: - Operation Overrides
    
    public final override var isReady: Bool {
        return state == .ready && super.isReady
    }
    
    public final override var isExecuting: Bool {
        return state == .executing
    }
    
    public final override var isFinished: Bool {
        return state == .finished
    }
    
    public final override var isAsynchronous: Bool {
        return true
    }
    
    public override final func start() {
        super.start()
        
        if isCancelled {
            return finish()
        }
        willStart()
        state = .executing
        execute()
    }
    
    // MARK: - Public
    
    open func execute() {
        fatalError("Subclasses must implement `execute`.")
    }
    
    open func finish() {
        willFinish()
        state = .finished
    }
}
