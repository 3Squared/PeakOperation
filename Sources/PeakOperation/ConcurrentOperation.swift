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
    public static let operationDidStart = Notification.Name("PeakOperation.ConcurrentOperation.operationDidStart")
    public static let operationWillFinish = Notification.Name("PeakOperation.ConcurrentOperation.operationWillFinish")
    public static let operationDidFinish = Notification.Name("PeakOperation.ConcurrentOperation.operationDidFinish")

    private var willStart: () -> Void = { }
    private var didStart: () -> Void = { }
    private var willFinish: () -> Void = { }
    private var didFinish: () -> Void = { }

    private let stateQueue = DispatchQueue(label: "PeakOperation.ConcurrentOperation.StateQueue", attributes: .concurrent)
    private var rawState = OperationState.ready
    
    public private(set) var startDate: Date?
    public private(set) var finishDate: Date?
    
    public var executionTime: TimeInterval {
        guard let startDate = startDate else { return 0 }
        let endDate = finishDate ?? Date()
        return endDate.timeIntervalSince(startDate)
    }
    
    public var progress = Progress(totalUnitCount: 100)
    internal var managesOwnProgress = false
    
    public lazy var internalQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "PeakOperation.ConcurrentOperation.InternalQueue"
        return queue
    }()
    
    @objc
    private dynamic var state: OperationState {
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
    private dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state"]
    }
    
    @objc
    private dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }
    
    @objc
    private dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
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
        
        startDate = Date()
        postNotification(ConcurrentOperation.operationDidStart)
        didStart()
        
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
    
    open override func cancel() {
        internalQueue.cancelAllOperations()
        super.cancel()
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
        
        finishDate = Date()
        postNotification(ConcurrentOperation.operationDidFinish)
        didFinish()
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
    
    /// Add a block to be called just after an operation begins executing.
    ///
    /// - Parameter block
    public func addDidStartBlock(block: @escaping () -> Void) {
        let existing = didStart
        didStart = {
            existing()
            block()
        }
    }
    
    /// Add a block to be called before finishing.
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
    
    /// Add a block to be called after finishing.
    /// Any output from an operation should be set by the time the block is called.
    ///
    /// - Parameter block
    public func addDidFinishBlock(block: @escaping () -> Void) {
        let existing = didFinish
        didFinish = {
            existing()
            block()
        }
    }
}
