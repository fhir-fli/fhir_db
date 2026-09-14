import 'package:fhir_db/src/search/search_parameter_types.dart';
import 'package:fhir_db/src/search/search_query_key.dart';
import 'package:fhir_node/fhir_node.dart';
import 'package:fhir_path/fhir_path.dart';

/// What the store needs from a FHIR version, supplied by a binding
/// (`fhir_r4_db`, `fhir_r5_db`, `fhir_r6_db`).
///
/// [R] is the binding's resource type (a [FhirNode]: `fhir_r4`'s `Resource`);
/// [T] its resource-type token (`R4ResourceType`), whose `toString()` is the
/// type name (`Patient`). The store itself reads resources through
/// [FhirNode] navigation and never constructs one: everything that builds a
/// value of the version's model goes through this class.
abstract class FhirModel<R extends FhirNode, T extends Object> {
  /// Creates a model.
  const FhirModel();

  /// The version's FHIR version string, `4.3.0`.
  String get fhirVersion;

  /// The resource type names of this version.
  Set<String> get resourceTypeNames;

  /// The type token for [name], or null when the version has no such
  /// resource type.
  T? typeFromName(String name);

  /// Parses a resource from its JSON text.
  R fromJson(String json);

  /// The JSON text of [resource].
  String toJson(R resource);

  /// Any element of the model as JSON (a Meta, a Period, a Timing): the
  /// store keeps a complex value as written in a few index columns.
  Map<String, dynamic> jsonOf(FhirNode element);

  /// [jsonOf] as text.
  String jsonText(FhirNode element);

  /// [resource] with [id] as its logical id.
  R withId(R resource, String id);

  /// [resource] with [meta] (a Meta as JSON) as its `meta`, replacing what
  /// was there.
  R withMeta(R resource, Map<String, dynamic> meta);

  /// The index rows of [resource]: the version's generated extractor.
  SearchParameterLists extract(R resource);

  /// The published SearchParameter definitions of this version, by
  /// resource type then code.
  SearchDefinitions get searchParameters;

  /// The published CompartmentDefinitions of this version: compartment
  /// type → member resource type → the parameters that link a member to
  /// the compartment.
  Map<String, Map<String, List<String>>> get compartmentDefinitions;

  /// For a bound `code` the model represents as an enum with its system
  /// attached (`fhir_r4`'s `FhirCodeEnum`), that system; null otherwise.
  /// A [FhirNode] exposes no such child, and the token index carries it.
  String? enumSystem(FhirNode value) => null;

  /// As [enumSystem], for the enum's display.
  String? enumDisplay(FhirNode value) => null;

  /// Whether `:below` on a mime-type token accepts the first segment alone.
  /// R4B search.html 3.1.1.4.10.1 (read whole 2026-09-09) gives only
  /// `contenttype:below=text/xml`; R5 search.html 3.2.1.6.4 (read whole
  /// 2026-09-09) adds, quoted verbatim: "Additionally, the below modifier
  /// can be applied to the first segment only:
  /// `contenttype:below=image` will match all image/ content types". The
  /// one place the three DAOs differed in behaviour before they became
  /// this package.
  bool get mimeTypeBelowMatchesFirstSegment => false;

  /// Which modifiers each search parameter type takes in this version, and
  /// which of those the store does not implement. R4B's tables unless the
  /// binding says otherwise; see [ModifierRules].
  ModifierRules get modifierRules => r4bModifierRules;

  /// The FHIRPath engine over this version, with [hostServices] as what the
  /// store answers to `resolve()` while indexing, or null when the model
  /// has none. Uploaded `SearchParameter` resources are indexed by
  /// evaluating their expressions with it; a model that returns null stores
  /// them and indexes nothing by them.
  Future<FHIRPathEngine>? createFhirPathEngine(
    IEvaluationContext hostServices,
  ) =>
      null;
}

/// Reads over any [FhirNode] the store makes everywhere.
extension FhirNodeReads on FhirNode {
  /// The primitive value of the child [name], or null.
  String? childValue(String name) => getChildByName(name)?.primitiveValue;

  /// The child [name], or null.
  FhirNode? child(String name) => getChildByName(name);

  /// The children [name].
  List<FhirNode> children(String name) => getChildrenByName(name);

  /// A resource's logical id, or null.
  String? get resourceId => childValue('id');

  /// A resource's `meta.versionId`, or null.
  String? get metaVersionId => child('meta')?.childValue('versionId');

  /// A resource's `meta.lastUpdated` as an instant, or null.
  DateTime? get metaLastUpdated {
    final written = child('meta')?.childValue('lastUpdated');
    return written == null ? null : DateTime.tryParse(written);
  }
}
