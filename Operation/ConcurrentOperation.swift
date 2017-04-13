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

/// A operation subclass that can perform work asynchronously.
///
/// Override `execute()` to perform your work. It is up to the user to perform the work on another thread - one is not made for you.
/// When your work is completed, call `finish()` to complete the operation.
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
    
    /// :nodoc:
    public final override var isReady: Bool {
        return state == .ready && super.isReady
    }
    
    
    /// :nodoc:
    public final override var isExecuting: Bool {
        return state == .executing
    }
    
    
    /// :nodoc:
    public final override var isFinished: Bool {
        return state == .finished
    }
    
    /// :nodoc:
    public final override var isAsynchronous: Bool {
        return true
    }
    
    /// :nodoc:
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
    
    
    /// Override this method to perform your work. 
    /// This will not be executed on a separate thread; it is your responsibiity to do so, if needed.
    ///
    /// Ensure you call `finish()` at some later point, or the operation will never complete.
    open func execute() {
        fatalError("Subclasses must implement `execute`.")
    }
    
    /// Call this method to indicate that your work is finished.
    open func finish() {
        willFinish()
        state = .finished
    }
}
