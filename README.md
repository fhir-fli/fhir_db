# fhir_db

Model-independent FHIR store on SQLite (via [Drift](https://drift.simonbinder.eu/)),
part of the [fhir-fli](https://github.com/fhir-fli) ecosystem.

**FHIR-free by design**: the store knows nothing about any FHIR version. A
resource is a `FhirNode` (`package:fhir_node`); the version enters through
`FhirModel<R>`, implemented by the thin `fhir_r4_db` / `fhir_r5_db` /
`fhir_r6_db` binding packages, which also carry the generated per-version
data (search parameter definitions, the index extractor, the compartment
definitions). Applications depend on a binding, not on this package.

```
resource (FhirNode) ──▶ FhirDao ──▶ resources / resources_history
                          │          + nine search-parameter index tables
                          ▼
                  FhirModel<R> (fhir_r*_db bindings supply FHIR)
```

## Usage (through a binding)

```dart
import 'package:fhir_r4_db/fhir_r4_db.dart';

final db = FhirDb(NativeDatabase(File('fhir.sqlite')));
await db.fhirDao.saveResource(patient);
final found = await db.fhirDao.search(
  resourceType: R4ResourceType.Patient,
  searchParameters: {'name': ['smith']},
);
```

What the store does: create/read/update/delete with versions and history
(the current version stored once; history holds superseded versions and
deletion tombstones), search over every FHIR search-parameter type with
modifiers, prefixes, chaining, `_has`, `_include`/`_revinclude` targets,
compartments, `_sort` and SQL paging, `:in`/`:below` through stored
ValueSets, optional SQLCipher encryption.

## History

Until 0.12.0 this package was a Sembast/Hive wrapper over the original
`fhir` package. 0.13.0 replaces it entirely; see the CHANGELOG.
