/// Not exported: shared by the store's own files.
library;

/// A table a store creates the first time it needs it (`store_clock`,
/// `search_parameter_generation`), so a subclass with its own migration
/// needs no step for it. Created inside a caller's transaction that then
/// rolls back, the table is gone though its creation completed: measured
/// 2026-11-24 (fhir_r4_db `search_parameter_two_connections_test.dart`),
/// a store whose first save was in a transaction that rolled back failed
/// every later save on that connection with "no such table: store_clock".
/// So a use that finds no table creates it again, once.
class CreatedOnFirstUse {
  /// Creates the table with [_create] at first use.
  CreatedOnFirstUse(this._create);

  final Future<void> Function() _create;
  Future<void>? _ready;

  /// Runs [body] once the table exists.
  Future<T> use<T>(Future<T> Function() body) async {
    await (_ready ??= _create());
    try {
      return await body();
    } on Object catch (e) {
      if (!'$e'.contains('no such table')) rethrow;
      _ready = null;
      await (_ready ??= _create());
      return body();
    }
  }
}
