# CHANGELOG

The changelog for `PeakOperation`.

--------------------------------------

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
