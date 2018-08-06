![Peak Operation](PeakOperation.png "Peak Operation")

PeakOperation is a Swift microframework providing enhancement and conveniences to [`Operation`](https://developer.apple.com/documentation/foundation/operation). It is part of the [Peak Framework](#peak-framework).

## Concurrent Operations

`ConcurrentOperation` is an abstract `Operation` subclass that can perform work asynchronously. You override `execute()` to perform your work, and when it is completed call `finish()` to complete the operation.

```swift
class MyOperation: ConcurrentOperation {
   override func execute() {
        print("Hello World!")
        finish()
    }
}

let queue = OperationQueue()
let operation = MyOperation()
operation.enqueue(on: queue)

```

This means that you can perform asynchronous work inside `execute()`, such as performing a `URLSession` request. 

## Chaining operations

`Operation` provides the ability to add dependencies between operations. PeakOperation builds upon this functionality and wraps it in an easy-to-use API.

```swift
let firstOperation = ...
let secondOperation = ...
        
firstOperation
    .then(do: secondOperation)
    .enqueue()
```

In the example above, `secondOperation` will run once `firstOperation` finishes.

You can also call `enqueueWithProgress()` on a chain of operations or `overallProgress()` on a single operation to track their progress.

```swift
let progress: Progress = firstOperation
    .then(do: secondOperation)
    .enqueueWithProgress()

// or

let progress: Progress = secondOperation.overallProgress()
```

## Passing Results

Adding dependencies between operations is useful, but passing results between operations is where PeakOperation really shines. PeakOperation includes two protocols your operation can conform to: `ProducesResult` and `ConsumesResult`. We use the `Result` type provided by [PeakResult]().

Let's say we have three operations. The first produces a `Result<Int>`.

```swift
class IntOperation: ConcurrentOperation, ProducesResult {
    var output: Result<Int>
    override func execute() {
        output = Result { 1 }
        finish()
    }
}
```

The second operation consumes a `Result<Int>` and produces a `Result<String>`. It unpacks its input, adds 1, converts it to a string, then sets it's output.

```swift
class AddOneOperation: ConcurrentOperation, ConsumesResult, ProducesResult {
    var input: Result<Int>
    var output: Result<String>
    override func execute() {
        output = Result { "\(try input.resolve() + 1)" }
        finish()
    }
}
```

The final operation consumes a `Result<String>`. It unpacks it and prints it to the console:

```swift
class PrintOperation: ConcurrentOperation, ConsumesResult {
    var input: Result<String>
    override func execute() {
        do {
            print("Hello \(try input.resolve())!")
        } catch { }
        finish()
    }
}
```

Using `passesResult(to:)`, these three operations can be chained together!

```swift
IntOperation()
    .passesResult(to: AddOneOperation())
    .passesResult(to: PrintOperation())
    .enqueue()

    // Hello 2!
```

As long as the input type matches the output type, you can pass results between any operations conforming to the protocols.

If any of the operations fail and its result is `.failure`, then the result will still be passed into the next operation. It's up to you to unwrap the result and deal with the error appropriately, perhaps by rethrowing the error.

```swift
class RethrowingOperation: ConcurrentOperation, ConsumesResult, ProducesResult {
    var input: Result<String>
    var output: Result<String>
    override func execute() {
        do {
            let _ = try input.resolve()
            output = ...
        } catch { 
            output = Result { throw error }
        }
        finish()
    }
}
```

That way, any of the operations can fail and you can still retrieve the error at the end.

```swift
let failingOperation = ...
let successfulOperation = ...
let anotherSuccessfulOperation = ...

failingOperation
    .passesResult(to: successfulOperation)
    .passesResult(to: anotherSuccessfulOperation)
    .enqueue()

anotherSuccessfulOperation.addResultBlock { result in
    // result would contain the error from failingOperation 
    // even though the other operations still ran
}
```

## Grouping

`GroupChainOperation` takes an operation and its dependants and executes them on an internal queue. The result of the operations is retained and it is inspected in order that this operation can produce a result of type ` Result<Void>` - the value is lost, but the `.success`/`.failure` is kept. This allows you to chain together groups with otherwise incompatible input/outputs.

```swift
// would otherwise produce String, now produces Void
let group1 = intOperation
    .passesResult(to: stringOperation)
    .group()

// Would otherwise accept Bool, now consumes Void
let group2 = boolOperation
    .passesResult(to: anyOperation)
    .group()

group1
    .passesResult(to: group2)
    .enqueue()

```

## Retrying

Sometimes an operation might fail. Perhaps you are dealing with a flaky web service or connection. For this, you can subclass `RetryingOperation`. This is an operation which `ProducesResult`, and if the result is `.failure`, it will try again using a given `retryStrategy` closure.

```swift
class MyRetryingOperation: RetryingOperation<AnyObject> {
   override func execute() {
        output = Result { throw error }
        finish()
    }
}

let operation = MyRetryingOperation()
operation.retryStrategy = { failureCount in
    return failureCount < 3
}
```

You can provide your own block as a `retryStrategy`. Here, the operation will be run 3 times before it finally fails.

There are 2 provided `StrategyBlocks`: 

- `RetryStrategy.none`
- `RetryStrategy.repeat(times: Int)`

## Examples

Please see the included tests for further examples. Also check out [PeakNetwork]() which uses PeakOperation extensively. 

## Getting Started

### Installing

- Using Cocoapods, add `pod 'PeakOperation'` to your Podfile.

- `import PeakOperation` where necessary.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

- [calebd/AsynchronousOperation.swift](https://gist.github.com/calebd/93fa347397cec5f88233)
- [ProcedureKit](https://github.com/ProcedureKit/ProcedureKit)

# Peak Framework

The Peak Framework is a collection of open-source microframeworks created by the team at [3Squared](https://github.com/3squared), named for the [Peak District](https://en.wikipedia.org/wiki/Peak_District). It is made up of:

|Name|Description|
|:--|:--|
|[PeakResult](https://github.com/3squared/PeakResult)|A simple `Result` type.|
|[PeakNetwork](https://github.com/3squared/PeakNetwork)|A networking framework built on top of `Session` using PeakOperation, leveraging the power of `Codable`.|
