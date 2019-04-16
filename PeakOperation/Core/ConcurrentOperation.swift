//
//  ConcurrentOperation.swift
//  PeakOperation
//
//  Created by David Yates on 05/04/2017.
//  Copyright © 2017 3Squared. All rights reserved.
//

// Adapted from: https://gist.github.com/calebd/93fa347397cec5f88233

import Foundation

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
    
    public static let operationWillStart = Notification.Name("PeakOperation.ConcurrentOperation.operationWillStart")
    public static let operationWillFinish = Notification.Name("PeakOperation.ConcurrentOperation.operationWillFinish")

    private var willStart: () -> Void = { }
    private var willFinish: () -> Void = { }
    
    public typealias TimeInSeconds = Int64
    
    fileprivate let stateQueue = DispatchQueue(label: "PeakOperation.ConcurrentOperation.StateQueue", attributes: .concurrent)
    fileprivate var rawState = OperationState.ready
    
    public var progress = Progress(totalUnitCount: 100)
    internal var managesOwnProgress = false
    
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
            
            if !managesOwnProgress {
                switch newValue {
                case .finished:
                    progress.completedUnitCount = progress.totalUnitCount
                default: break;
                }
            }

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
        
        postNotification(ConcurrentOperation.operationWillStart)
        willStart()
        state = .executing
        execute()
    }
    
    private func postNotification(_ notification: Notification.Name) {
        var userInfo = [String: String]()

        if let name = name {
            userInfo["name"] = name
        }

        if let queueName = OperationQueue.current?.name {
            userInfo["queue"] = queueName
        }

        NotificationCenter.default.post(
            name: notification,
            object: self,
            userInfo: userInfo
        )
    }
    
    // MARK: - Public
    
    open override var description: String {
        return "\(String(describing: type(of: self)))(name: '\(name ?? "nil")', state: \(state.rawValue))"
    }
    
    /// Override this method to perform your work. 
    /// This will not be executed on a separate thread; it is your responsibiity to do so, if needed.
    ///
    /// Ensure you call `finish()` at some later point, or the operation will never complete.
    open func execute() {
        fatalError("Subclasses must implement `execute`.")
    }
    
    /// Call this method to indicate that your work is finished. Ensure you call `super.finish()`.
    open func finish() {
        postNotification(ConcurrentOperation.operationWillFinish)
        willFinish()
        state = .finished
    }
    
    /// Add a block to be called just before an operation begins executing.
    /// Any inputs to an operation is not guaranteed to be set by the time the block is called.
    ///
    /// - Parameter block
    public func addWillStartBlock(block: @escaping () -> Void) {
        let existing = willStart
        willStart = {
            existing()
            block()
        }
    }
    
    /// Add a block to be called after execution has finished.
    /// Any output from an operation should be set by the time the block is called.
    ///
    /// - Parameter block
    public func addWillFinishBlock(block: @escaping () -> Void) {
        let existing = willFinish
        willFinish = {
            existing()
            block()
        }
    }
}
