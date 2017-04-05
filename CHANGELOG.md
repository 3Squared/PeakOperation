# CHANGELOG

The changelog for `THROperation`.

--------------------------------------

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