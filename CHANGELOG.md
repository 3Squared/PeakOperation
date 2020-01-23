# CHANGELOG

The changelog for `PeakOperation`.

--------------------------------------

4.1.0
-----
- Adds an internal dispatch queue to `ConcurrentOperation`.
- Adds `startDate`, `finishDate` and `executionTime` properties to `ConcurrentOperation`.
- Add notifications and blocks for `didStart` and `didFinish`.

4.0.1
-----
- Fix issue where cancelling a `GroupChainOperation` would not cancel its children.

4.0.0
-----
- Add notifications that are posted on start/finish of `ConcurrentOperation`.
- Rename `overallProgress` to `chainProgress`.
- Fix issues with `chainProgress` reporting incorrect values.
- Make `operationChain` public, available on all `Operations`.

3.2.0
-----
- Remove PeakResult as a dependency in favour of Swift 5's native Result.
- Update project to Swift 5.


3.1.0
-----
- Allow passing of result to multiple dependants
- Allow receiving of multiple results by a dependant 
- Make willStart/Finish publicly settable
- Add method that passes only error
- Infer type of operation passed into `then(do:)` function

3.0.0
-----
- Make it easier to subclass `MapOperation`.
- Replace old `MapOperation` with `BlockMapOperation`.
- Add method to enqueue and set a result block together.

2.2.1
-----
- Add macOS and tvOS support.

2.0.0
-----
- Rename from `THROperations` to `PeakOperation`.

1.4.3
-----
- Make reference to operation unowned.

1.4.2
-----
- Remove retain cycles.

1.4.1
-----
- Bump minimum deployment target to 10.0.

1.4.0
-----
- Update for Swift 4.1

1.3.0
-----
- Add more detailed progress to `GroupChainOperation`
- Add Fastlane to project for automated testing

1.2.0
-----
- Fix incorrect access level in `GroupChainOperation`

1.1.0
-----
- Add `progress` to ConcurrentOperations, allowing the tracking of a set of chained operations

1.0.0
-----
- Fix issue with `then(..)` where dependancy was set up wrong-way-round
- Update to Swift 4

0.2.0
-----
- Ensure thread-safety in state changes in BaseOperation
- Rename BaseOperation -> ConcurrentOperation
- Rename run() -> execute()

0.1.0
-----
- If an operation is cancelled, do not pass its result along
- Combine Base and ConcurrentOperation
- Rename ObservableOperation to BaseOperation
- Add `enqueueAll()` for use with `passesResult(to:)` operation composition
- Inject the result of an operation into its dependants

0.0.2
-----
- Remove unused error types.
