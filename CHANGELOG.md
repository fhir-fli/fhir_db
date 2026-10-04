# fhir_db

## [0.15.0]

- Depends on `fhir_path` ^0.15.0 (0.14.2 was never published; the
  constraint did not admit the 0.15.0 the bindings use).
- **A fetched resource can keep its server's `meta`**: `saveResource` and
  `saveResources` take `preserveMeta`. When it is set and the resource
  carries a `meta.lastUpdated`, the meta is stored exactly as received —
  versionId, lastUpdated, tags — instead of being stamped with this store's
  time and next version. For a client caching another server's resources,
  the stamp made every cached row show the time of the last sync, and a
  newer remote edit lost a "which is newer?" comparison to a local write
  time. Off by default; a resource with no `lastUpdated` is versioned as
  before. Proposed and first implemented by **xtMartinEberl** against
  fhir_r4_db 0.12.0 (fhir-fli/fhir_r4 issue #39, PR #40, 2026-09-17); the
  save code had since moved here, so it lands in the core and every binding
  inherits it. `test/preserve_meta_test.dart`.
- `FhirModel<R, T>` extends fhir_node 0.6.1's `ResourceModel<R>`: a binding
  now gives `fromJson(Map)` / `toJson(R)` (the map) as well as the store's
  text pair, renamed `fromJsonText` / `toJsonText`. The tests' JSON node is
  fhir_node's `JsonNode` with this package's element-type table.

- **Every search shape but two is answered in SQL** (fhirant
  REVIEW-2026-09-17 ST4, step 1 of 4). The Dart set path, which read every
  matching id into memory, is now reached only for a token `:of-type` and
  an `_id` list longer than 500. What moved, and what changed with it
  (R4B search.html, read whole 2026-10-01):
  - `_count=0` is an empty page (3.1.1.5.3). The set path returned every
    match for it.
  - `_id:missing` and `_lastUpdated:missing` are answered (every resource
    has both). Any other modifier on `_id` or `_lastUpdated` is refused
    (`UnsupportedSearchModifier`); `_id:not=x` used to answer x itself.
  - `_list` and `_content` take no modifier (refused); `_text` takes the
    string ones (`:exact`, `:contains`, `:missing`).
  - A reference type modifier that names no resource type (`subject:Foo`)
    is refused (3.1.1.4.4), where it answered as empty. With a typed
    value, `subject:Patient=Patient/1` is that search and
    `subject:Patient=Encounter/1` is empty.
  - A chain on a parameter that is not a reference is empty (3.1.1.4.15).
  - A chained parameter no target type defines, or an unknown parameter
    inside `_has`, is ignored (3.1.1.3), as an unknown top-level parameter
    is. The set path matched every target with it, which turned
    `subject.nonsense=x` into "has any subject".
  - `_has` naming a type the store has no definition for is empty.
  - A `_sort` rule naming no parameter, or a composite or special one, is
    dropped; the rules after it still apply (3.1.1.5.1).
  - A number, quantity, date, uri, string, special or composite modifier
    the builders have no meaning for is refused rather than passed on.
- **An `_id` list or caller id set of any length is searched in SQL**
  (ST4, step 2 of 4). Past 500 values the list is one literal JSON array
  read with `json_each` (SQLite ≥ 3.38.0), not one bound `id = ?` per
  value; 40,000 ids answer in well under a second where the bound form
  overflowed the stack.
- **`identifier:of-type` is indexed and searched in SQL** (ST4, step 3 of
  4). The indexer writes one token row named `<param>:of-type` per
  `Identifier.type.coding` (system = the coding's system, value =
  `<type code>|<identifier value>`, HAPI's layout), and the search is a
  plain equality on those rows. R4B search.html 3.1.1.4.10: "All 3 parts
  must be present" — two parts is `InvalidSearchValue`. **Schema 15**:
  the upgrade re-extracts the search index so stored resources get their
  rows; a subclass with its own migration (fhirant_db) adds the same
  rebuild at its next version.
- **The Dart set path is deleted** (ST4, step 4 of 4): `_matchingIds`,
  the ten `_search*Parameter` walkers, the Dart sort and page, 1,361
  lines. `search`, `searchIds` and `searchCount` run one SQL statement
  each. `FhirDao.lastSearchPagedInSql`, the test-visible flag that said
  which path ran, is gone with the second path.

## [0.14.0]

- **`purgeResourcesLastUpdatedBefore(type, cutoff)`** (fhirant
  REVIEW-2026-09-17 A16): removes every resource of a type whose current
  version is older than the cutoff, with its history and index rows, and no
  tombstone. Retention, not a client delete; fhirant sweeps AuditEvents
  with it.
- **Compartment membership honours `serverBaseUrl`** (fhirant
  REVIEW-2026-09-17 A16): with the base known, a resource whose reference
  is `Patient/p1` on ANOTHER server is not in this server's `Patient/p1`
  compartment, the same rule the reference search and `_include` already
  applied. Without a base the store cannot tell and admits it, as before.
- **`:identifier=|[value]` matches only an identifier with no system**
  (fhirant REVIEW-2026-09-17 Q5). R4B 3.1.1.4.12: with `:identifier` "the
  search value works as a token search", and 3.1.1.4.10 gives the leading
  pipe its own meaning: the Identifier "has no system property". It was
  read as a bare value, so `subject:identifier=|42` also matched a
  reference whose identifier has a system. One condition builder now serves
  both search paths.
- **`:missing` takes `true` or `false` and nothing else** (fhirant
  REVIEW-2026-09-17 Q4). R4B search.html 3.1.1.4.4: ":missing; e.g.
  gender:missing=true (or false)". Any other value was read as false, so
  `gender:missing=maybe` answered "present"; it is `InvalidSearchValue` now,
  on both search paths, and the value is read case-insensitively.
- **`:text` on a string parameter and a literal `:type` on a reference are
  refused** (fhirant REVIEW-2026-09-17 Q3). R4B search.html 3.1.1.4.4, read
  whole: string takes `:exact` and `:contains`; reference takes `:[type]`,
  a placeholder for a resource type, `:identifier`, `:above` and `:below`.
  `modifiersByType` listed `text` under string and the word `type` under
  reference, so `name:text=tex` was answered as a starts-with match and
  `subject:type=Patient` as nothing, where the page's SHALL is a 400.
- **`rebuildSearchIndex` builds beside the live index and swaps in one
  transaction.** It dropped the nine index tables first and refilled them
  in place, so a search that ran meanwhile read a half-built index and a
  save meanwhile failed on the missing table (fhirant REVIEW-2026-09-17
  Q2). Now the tables are built again as `<table>_rebuild` (the current
  schema, through the migrator), then one transaction drops the old tables,
  renames the new ones in, creates the value indexes under their own names,
  re-extracts every resource saved since the rebuild began and drops the
  rows of every resource deleted since. Searches wait for that transaction
  and never see between its steps. An event-loop turn between pages lets a
  server whose store runs on its own isolate keep serving.
- **A date with no zone is read on the UTC clock, in the index and in a
  search.** It was read in the process's local zone, which on a phone moves:
  a store indexed under one zone and searched under another lost every
  equality match on a zone-less date, `birthDate` first of all (fhirant
  REVIEW-2026-09-17 Q1). R4B search 3.1.1.4.7 asks that "the servers local
  time zone should be assumed" where neither side has a zone; any one zone
  on both sides answers that the same, and UTC does not move. A zone-less
  value against a zoned one is now compared on the UTC clock. Stores indexed
  before this need a reindex.
- **One value set expansion, which refuses what it cannot evaluate.**
  `FhirDao.expandValueSet(valueSet)` and `expandValueSetByUrl(url)` are
  public and return system, code and display; `:in` and `:not-in` use them,
  and a server's `$expand` and `$validate-code` should. **Breaking for
  searches that used to answer wrongly:** a ValueSet the store does not hold
  (`ValueSetNotHeld`), and a whole-CodeSystem include whose CodeSystem is
  not held, not held in the version asked for, or held with `content` other
  than `complete` (`CodeSystemNotEvaluable`), now throw. They used to expand
  to no codes, so `:in` matched nothing and `:not-in` matched everything.
  `include.version` is honoured. All refusals, `UnsupportedValueSetCompose`
  included, implement `ValueSetRefusal` (`message`, `issueCode`). An include
  that lists its concepts needs no CodeSystem and is not refused (fhirant
  REVIEW-2026-09-17 T1, T2).
- **A save made `asServer` is not checked as an uploaded SearchParameter.**
  A server's own definitions (fhirant loads the specification's 1,414) are
  the ones the generated extractor implements; checked as uploads they are
  all refused (no expression, or a code an upload may not redefine) and the
  batch save throws. They are stored as documents, and the registry lists
  them as not indexed by, as before. A client's save is checked as it was.
- **Server-owned tags.** `FhirDao.serverOwnedTags` names `meta.tag` codings
  (`system|code`) only the server writes. A save made without
  `asServer: true` (new on `saveResource` and `saveResources`) neither adds
  one nor keeps one through the tag merge; a resource a client has written
  is never marked as the server's. Empty by default, so nothing changes for
  a store that declares none. fhirant keys what `$backup` and a system
  `$export` leave out on such a tag, and a client could write it (fhirant
  REVIEW-2026-09-17 S3).
- **Uploaded `SearchParameter` resources are indexed.** A stored
  `SearchParameter` with `status: active` is evaluated with the FHIRPath
  engine on every save of a resource its `base` covers, and its rows go to
  the table its `type` names, through the same row builders the generated
  extractor uses (`CustomSearchParameters`, loaded from the store on first
  use, reloaded when a SearchParameter is saved or deleted). The query side
  routes an uploaded code the same way (`FhirDao.lookupDefinition`).
  `rebuildSearchIndex()` indexes existing resources by it: the reindex
  (a schema migration's rebuild passes `includeUploaded: false`, since the
  store is still opening; run a reindex after upgrading).
  What HAPI/Smile CDR and the Azure FHIR service do for every parameter;
  the specification's own set keeps the generated extractor (measured 1.4
  to 6 times faster on the MIMIC sample).
- A definition the store cannot index by is refused at save with
  `InvalidSearchParameter`: no code, base or expression; a type other than
  string/token/reference/date/quantity/number/uri/special; a base that is
  not a resource type of the version; a code the specification already
  defines on that base; an expression that does not parse. An inactive
  definition is stored and indexes nothing.
- `resolve()` while indexing answers a resource of the referenced type
  from the reference string alone (`IndexHostServices`), so
  `subject.where(resolve() is Patient)` holds for `Patient/123` whether or
  not that Patient is stored, as the generated extractor's string test does.
  Needs `fhir_path` 0.14.2.
- `FhirModel.createFhirPathEngine(hostServices)`: a binding supplies its
  engine; a model returning null (the default) stores SearchParameters and
  indexes nothing by them.

## [0.13.0]

The package is reborn as the model-independent core of the fhir-fli SQLite
store. Until 0.12.0 it was a Sembast/Hive wrapper over the pre-`fhir_r4`
`fhir` package; that API is gone. What replaces it is the store that lived
in `fhir_r4_db`, `fhir_r5_db` and `fhir_r6_db` as three hand-kept copies
(75 of 4,406 DAO lines differed between r4 and r5, all version names):

- **One store over `FhirNode`.** Resources, versions and history (schema 14:
  the current version stored once, history holding what a save replaced and
  the tombstones), the nine search-parameter index tables, compartments,
  `_has`, `_include` targets, ValueSet expansion for `:in`/`:below`, the
  SQLCipher key derivation. The FHIR version enters through
  `FhirModel<R extends FhirNode>`: the resource type of a value, JSON in and
  out, meta stamping, and the three generated per-version artefacts (search
  parameter definitions, the index extractor, the compartment definitions).
- **Bindings.** `fhir_r4_db`, `fhir_r5_db` and `fhir_r6_db` re-export this
  package and add the generated data, a `FhirModel` for their version and
  the typed API they always had; an application imports the binding only.
- Schema and behaviour are those of `fhir_r4_db` 0.12.0 + its unreleased
  changes (schema 13 and 14); an existing database opens unchanged.

## [0.12.0]
 
* Updated dependencies
* Listen now works

## [0.11.0-dev5]
* fixed search (Thanks to the PR from [nikolaydymura](https://github.com/nikolaydymura))

## [0.11.0-4]

* Updated Dependencies
* Simplifed the number files (merged FhirDbDao and FhirDb - I think most people want to make their own interface classes)

## [0.11.0-3]

* Trying to score more pub points

## [0.11.0-2]

* Updated dependencies

## [0.11.0-1]

* Major changes, including breaking changes
* Changed to use Hive instead of Sembast/SQLFlite
* Similar methods and setup, but not identical
* Updated dependencies

## [0.9.5]

* Updated dependencies

## [0.9.4]

* Updated dependencies
* Updated to fhir 0.9.4
* Updated to Dart 2.19.0

## [0.9.3]

* updated dependencies
* Accepted PR from [Aliaksei](https://github.com/AliakseiT) to ensure that when the db is updated to a different password (and the file is copied over temporarily), we await it, or else it fails sometimes

## [0.9.2]

* updated dependencies

## [0.9.1]

* updated dependencies

## [0.9.0]

* updated dependencies
* FHIR 0.9.0

## [0.8.0]

* updated dependencies
* FHIR 0.8.0
* Dart 2.17.0 & Flutter 3.0

## [0.6.1]

* updated dependencies (includin fhir 0.6.2)
* the resourceTypeString is now a getter, not a function
* sorting imports

## [0.6.0]

* Updated dependencies
* Updating to 0.6.0

## [0.5.0-6]

* Updated dependencies

## [0.5.0-5]

* Added an example

## [0.5.0-4]

* I forgot to update something in the fhir package

## [0.5.0-3]

* Updated dependencies

* Change the functions for new versions & new IDs

## [0.5.0-2]

* Updating to Dart 2.14.0
* Removed api files from repository

## [0.5.0-1]

* Updating dependencies
* I think [Luca](https://github.com/lucaspal) added some changes too, but I can't remember what they are now (it's what happens when I wait too long to commit)

## [0.4.4]

* Failed to properly commit changes in 0.4.3

## [0.4.3]

* Thanks to [Luca](https://github.com/lucaspal) for these updates!
* Can now close the DB, delete the DB file, and sets completer to null (since the database method relies on this to be null to open a new database)
* Using fhir_db as local cache (updating resources but not increasing version #)
* Pass the mode to the ResourceDAO, so new cache related features can be introduced in the future, without changing the API of the existing methods (or without having to introduce a twin method for each operation).

I intentionally made the field optional to avoid breaking changes and bother existing users.

## [0.4.2]

* Updating dependencies

## [0.4.1]

* Trying to improve comments

## [0.4.0]

* Stable null safety!

## [0.3.0-nullsafety.1]

* Updated dependencies
* Moved to dart 2.12.1 - stable channel

## [0.3.0-nullsafety.0]

* Null safety!
* Should be completely ready for null safety
* Finally got around to updating this package
* Should generally work the same as previously, you'll just need to follow null safety requirements

## [0.2.4]

* Updated Dependencies for base FHIR package new Date functionality

## [0.2.1]

* Updated Dependencies

## [0.2.0]

* Adjusted the way I change passwords
* Created tests to ensure proper functioning
* Upgraded dependencies

## [0.1.2]

* Added FHIR® to the Readme because we have official permission from HL7 and Graham Grieve!

## [0.1.1]

* Testing app was moved into example folder, because it provides a good example, and because I want my pub points!

## [0.1.0]

* To keep in line with the save FHIR package version
* updateVersion() function added to FHIR package, removed from this one
* added more comments

## [0.0.4]

* Made a general export file

## [0.0.3]

* Added a general store to allow the storage of generic maps in DB as well as FHIR resources

## [0.0.2]

* Made changes to links in readme
* Updated dependencies
* Added documentation

## [0.0.1]

* Created 2020-10-16
* Wrapper for Sembast_SQFLite allowing easy, secure, encrypted storage of FHIR resources
