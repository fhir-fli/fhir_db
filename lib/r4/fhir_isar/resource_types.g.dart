// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_types.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetResourceTypesCollection on Isar {
  IsarCollection<int, ResourceTypes> get resourceTypes => this.collection();
}

const ResourceTypesSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'ResourceTypes',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'resourceTypes',
        type: IsarType.byteList,
        enumMap: {
          "Account": 0,
          "ActivityDefinition": 1,
          "AdministrableProductDefinition": 2,
          "AdverseEvent": 3,
          "AllergyIntolerance": 4,
          "Appointment": 5,
          "AppointmentResponse": 6,
          "AuditEvent": 7,
          "Basic": 8,
          "Binary": 9,
          "BiologicallyDerivedProduct": 10,
          "BodyStructure": 11,
          "Bundle": 12,
          "CapabilityStatement": 13,
          "CarePlan": 14,
          "CareTeam": 15,
          "CatalogEntry": 16,
          "ChargeItem": 17,
          "ChargeItemDefinition": 18,
          "Citation": 19,
          "Claim": 20,
          "ClaimResponse": 21,
          "ClinicalImpression": 22,
          "ClinicalUseDefinition": 23,
          "CodeSystem": 24,
          "Communication": 25,
          "CommunicationRequest": 26,
          "CompartmentDefinition": 27,
          "Composition": 28,
          "ConceptMap": 29,
          "Condition": 30,
          "Consent": 31,
          "Contract": 32,
          "Coverage": 33,
          "CoverageEligibilityRequest": 34,
          "CoverageEligibilityResponse": 35,
          "DetectedIssue": 36,
          "Device": 37,
          "DeviceDefinition": 38,
          "DeviceMetric": 39,
          "DeviceRequest": 40,
          "DeviceUseStatement": 41,
          "DiagnosticReport": 42,
          "DocumentManifest": 43,
          "DocumentReference": 44,
          "Encounter": 45,
          "Endpoint": 46,
          "EnrollmentRequest": 47,
          "EnrollmentResponse": 48,
          "EpisodeOfCare": 49,
          "EventDefinition": 50,
          "Evidence": 51,
          "EvidenceReport": 52,
          "EvidenceVariable": 53,
          "ExampleScenario": 54,
          "ExplanationOfBenefit": 55,
          "FamilyMemberHistory": 56,
          "Flag": 57,
          "Goal": 58,
          "GraphDefinition": 59,
          "Group": 60,
          "GuidanceResponse": 61,
          "HealthcareService": 62,
          "ImagingStudy": 63,
          "Immunization": 64,
          "ImmunizationEvaluation": 65,
          "ImmunizationRecommendation": 66,
          "ImplementationGuide": 67,
          "Ingredient": 68,
          "InsurancePlan": 69,
          "Invoice": 70,
          "Library": 71,
          "Linkage": 72,
          "List": 73,
          "Location": 74,
          "ManufacturedItemDefinition": 75,
          "Measure": 76,
          "MeasureReport": 77,
          "Media": 78,
          "Medication": 79,
          "MedicationAdministration": 80,
          "MedicationDispense": 81,
          "MedicationKnowledge": 82,
          "MedicationRequest": 83,
          "MedicationStatement": 84,
          "MedicinalProductDefinition": 85,
          "MessageDefinition": 86,
          "MessageHeader": 87,
          "MolecularSequence": 88,
          "NamingSystem": 89,
          "NutritionOrder": 90,
          "NutritionProduct": 91,
          "Observation": 92,
          "ObservationDefinition": 93,
          "OperationDefinition": 94,
          "OperationOutcome": 95,
          "Organization": 96,
          "OrganizationAffiliation": 97,
          "PackagedProductDefinition": 98,
          "Parameters": 99,
          "Patient": 100,
          "PaymentNotice": 101,
          "PaymentReconciliation": 102,
          "Person": 103,
          "PlanDefinition": 104,
          "Practitioner": 105,
          "PractitionerRole": 106,
          "Procedure": 107,
          "Provenance": 108,
          "Questionnaire": 109,
          "QuestionnaireResponse": 110,
          "RegulatedAuthorization": 111,
          "RelatedPerson": 112,
          "RequestGroup": 113,
          "ResearchDefinition": 114,
          "ResearchElementDefinition": 115,
          "ResearchStudy": 116,
          "ResearchSubject": 117,
          "RiskAssessment": 118,
          "Schedule": 119,
          "SearchParameter": 120,
          "ServiceRequest": 121,
          "Slot": 122,
          "Specimen": 123,
          "SpecimenDefinition": 124,
          "StructureDefinition": 125,
          "StructureMap": 126,
          "Subscription": 127,
          "SubscriptionStatus": 128,
          "SubscriptionTopic": 129,
          "Substance": 130,
          "SubstanceDefinition": 131,
          "SupplyDelivery": 132,
          "SupplyRequest": 133,
          "Task": 134,
          "TerminologyCapabilities": 135,
          "TestReport": 136,
          "TestScript": 137,
          "ValueSet": 138,
          "VerificationResult": 139,
          "VisionPrescription": 140
        },
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, ResourceTypes>(
    serialize: serializeResourceTypes,
    deserialize: deserializeResourceTypes,
    deserializeProperty: deserializeResourceTypesProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeResourceTypes(IsarWriter writer, ResourceTypes object) {
  {
    final list = object.resourceTypes;
    final listWriter = IsarCore.beginList(writer, 1, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeByte(listWriter, i, list[i].index);
    }
    IsarCore.endList(writer, listWriter);
  }
  return object.id;
}

@isarProtected
ResourceTypes deserializeResourceTypes(IsarReader reader) {
  final List<R4ResourceType> _resourceTypes;
  {
    final length = IsarCore.readList(reader, 1, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _resourceTypes = const <R4ResourceType>[];
      } else {
        final list = List<R4ResourceType>.filled(length, R4ResourceType.Account,
            growable: true);
        for (var i = 0; i < length; i++) {
          {
            if (IsarCore.readNull(reader, i)) {
              list[i] = R4ResourceType.Account;
            } else {
              list[i] =
                  _resourceTypesResourceTypes[IsarCore.readByte(reader, i)] ??
                      R4ResourceType.Account;
            }
          }
        }
        IsarCore.freeReader(reader);
        _resourceTypes = list;
      }
    }
  }
  final object = ResourceTypes(
    _resourceTypes,
  );
  object.id = IsarCore.readId(reader);
  return object;
}

@isarProtected
dynamic deserializeResourceTypesProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      {
        final length = IsarCore.readList(reader, 1, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <R4ResourceType>[];
          } else {
            final list = List<R4ResourceType>.filled(
                length, R4ResourceType.Account,
                growable: true);
            for (var i = 0; i < length; i++) {
              {
                if (IsarCore.readNull(reader, i)) {
                  list[i] = R4ResourceType.Account;
                } else {
                  list[i] = _resourceTypesResourceTypes[
                          IsarCore.readByte(reader, i)] ??
                      R4ResourceType.Account;
                }
              }
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

const _resourceTypesResourceTypes = {
  0: R4ResourceType.Account,
  1: R4ResourceType.ActivityDefinition,
  2: R4ResourceType.AdministrableProductDefinition,
  3: R4ResourceType.AdverseEvent,
  4: R4ResourceType.AllergyIntolerance,
  5: R4ResourceType.Appointment,
  6: R4ResourceType.AppointmentResponse,
  7: R4ResourceType.AuditEvent,
  8: R4ResourceType.Basic,
  9: R4ResourceType.Binary,
  10: R4ResourceType.BiologicallyDerivedProduct,
  11: R4ResourceType.BodyStructure,
  12: R4ResourceType.Bundle,
  13: R4ResourceType.CapabilityStatement,
  14: R4ResourceType.CarePlan,
  15: R4ResourceType.CareTeam,
  16: R4ResourceType.CatalogEntry,
  17: R4ResourceType.ChargeItem,
  18: R4ResourceType.ChargeItemDefinition,
  19: R4ResourceType.Citation,
  20: R4ResourceType.Claim,
  21: R4ResourceType.ClaimResponse,
  22: R4ResourceType.ClinicalImpression,
  23: R4ResourceType.ClinicalUseDefinition,
  24: R4ResourceType.CodeSystem,
  25: R4ResourceType.Communication,
  26: R4ResourceType.CommunicationRequest,
  27: R4ResourceType.CompartmentDefinition,
  28: R4ResourceType.Composition,
  29: R4ResourceType.ConceptMap,
  30: R4ResourceType.Condition,
  31: R4ResourceType.Consent,
  32: R4ResourceType.Contract,
  33: R4ResourceType.Coverage,
  34: R4ResourceType.CoverageEligibilityRequest,
  35: R4ResourceType.CoverageEligibilityResponse,
  36: R4ResourceType.DetectedIssue,
  37: R4ResourceType.Device,
  38: R4ResourceType.DeviceDefinition,
  39: R4ResourceType.DeviceMetric,
  40: R4ResourceType.DeviceRequest,
  41: R4ResourceType.DeviceUseStatement,
  42: R4ResourceType.DiagnosticReport,
  43: R4ResourceType.DocumentManifest,
  44: R4ResourceType.DocumentReference,
  45: R4ResourceType.Encounter,
  46: R4ResourceType.Endpoint,
  47: R4ResourceType.EnrollmentRequest,
  48: R4ResourceType.EnrollmentResponse,
  49: R4ResourceType.EpisodeOfCare,
  50: R4ResourceType.EventDefinition,
  51: R4ResourceType.Evidence,
  52: R4ResourceType.EvidenceReport,
  53: R4ResourceType.EvidenceVariable,
  54: R4ResourceType.ExampleScenario,
  55: R4ResourceType.ExplanationOfBenefit,
  56: R4ResourceType.FamilyMemberHistory,
  57: R4ResourceType.Flag,
  58: R4ResourceType.Goal,
  59: R4ResourceType.GraphDefinition,
  60: R4ResourceType.Group,
  61: R4ResourceType.GuidanceResponse,
  62: R4ResourceType.HealthcareService,
  63: R4ResourceType.ImagingStudy,
  64: R4ResourceType.Immunization,
  65: R4ResourceType.ImmunizationEvaluation,
  66: R4ResourceType.ImmunizationRecommendation,
  67: R4ResourceType.ImplementationGuide,
  68: R4ResourceType.Ingredient,
  69: R4ResourceType.InsurancePlan,
  70: R4ResourceType.Invoice,
  71: R4ResourceType.Library,
  72: R4ResourceType.Linkage,
  73: R4ResourceType.List,
  74: R4ResourceType.Location,
  75: R4ResourceType.ManufacturedItemDefinition,
  76: R4ResourceType.Measure,
  77: R4ResourceType.MeasureReport,
  78: R4ResourceType.Media,
  79: R4ResourceType.Medication,
  80: R4ResourceType.MedicationAdministration,
  81: R4ResourceType.MedicationDispense,
  82: R4ResourceType.MedicationKnowledge,
  83: R4ResourceType.MedicationRequest,
  84: R4ResourceType.MedicationStatement,
  85: R4ResourceType.MedicinalProductDefinition,
  86: R4ResourceType.MessageDefinition,
  87: R4ResourceType.MessageHeader,
  88: R4ResourceType.MolecularSequence,
  89: R4ResourceType.NamingSystem,
  90: R4ResourceType.NutritionOrder,
  91: R4ResourceType.NutritionProduct,
  92: R4ResourceType.Observation,
  93: R4ResourceType.ObservationDefinition,
  94: R4ResourceType.OperationDefinition,
  95: R4ResourceType.OperationOutcome,
  96: R4ResourceType.Organization,
  97: R4ResourceType.OrganizationAffiliation,
  98: R4ResourceType.PackagedProductDefinition,
  99: R4ResourceType.Parameters,
  100: R4ResourceType.Patient,
  101: R4ResourceType.PaymentNotice,
  102: R4ResourceType.PaymentReconciliation,
  103: R4ResourceType.Person,
  104: R4ResourceType.PlanDefinition,
  105: R4ResourceType.Practitioner,
  106: R4ResourceType.PractitionerRole,
  107: R4ResourceType.Procedure,
  108: R4ResourceType.Provenance,
  109: R4ResourceType.Questionnaire,
  110: R4ResourceType.QuestionnaireResponse,
  111: R4ResourceType.RegulatedAuthorization,
  112: R4ResourceType.RelatedPerson,
  113: R4ResourceType.RequestGroup,
  114: R4ResourceType.ResearchDefinition,
  115: R4ResourceType.ResearchElementDefinition,
  116: R4ResourceType.ResearchStudy,
  117: R4ResourceType.ResearchSubject,
  118: R4ResourceType.RiskAssessment,
  119: R4ResourceType.Schedule,
  120: R4ResourceType.SearchParameter,
  121: R4ResourceType.ServiceRequest,
  122: R4ResourceType.Slot,
  123: R4ResourceType.Specimen,
  124: R4ResourceType.SpecimenDefinition,
  125: R4ResourceType.StructureDefinition,
  126: R4ResourceType.StructureMap,
  127: R4ResourceType.Subscription,
  128: R4ResourceType.SubscriptionStatus,
  129: R4ResourceType.SubscriptionTopic,
  130: R4ResourceType.Substance,
  131: R4ResourceType.SubstanceDefinition,
  132: R4ResourceType.SupplyDelivery,
  133: R4ResourceType.SupplyRequest,
  134: R4ResourceType.Task,
  135: R4ResourceType.TerminologyCapabilities,
  136: R4ResourceType.TestReport,
  137: R4ResourceType.TestScript,
  138: R4ResourceType.ValueSet,
  139: R4ResourceType.VerificationResult,
  140: R4ResourceType.VisionPrescription,
};

extension ResourceTypesQueryFilter
    on QueryBuilder<ResourceTypes, ResourceTypes, QFilterCondition> {
  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      resourceTypesElementEqualTo(
    R4ResourceType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      resourceTypesElementGreaterThan(
    R4ResourceType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      resourceTypesElementGreaterThanOrEqualTo(
    R4ResourceType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      resourceTypesElementLessThan(
    R4ResourceType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      resourceTypesElementLessThanOrEqualTo(
    R4ResourceType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      resourceTypesElementBetween(
    R4ResourceType lower,
    R4ResourceType upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      resourceTypesIsEmpty() {
    return not().resourceTypesIsNotEmpty();
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterFilterCondition>
      resourceTypesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 1, value: null),
      );
    });
  }
}

extension ResourceTypesQueryObject
    on QueryBuilder<ResourceTypes, ResourceTypes, QFilterCondition> {}

extension ResourceTypesQuerySortBy
    on QueryBuilder<ResourceTypes, ResourceTypes, QSortBy> {
  QueryBuilder<ResourceTypes, ResourceTypes, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }
}

extension ResourceTypesQuerySortThenBy
    on QueryBuilder<ResourceTypes, ResourceTypes, QSortThenBy> {
  QueryBuilder<ResourceTypes, ResourceTypes, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<ResourceTypes, ResourceTypes, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }
}

extension ResourceTypesQueryWhereDistinct
    on QueryBuilder<ResourceTypes, ResourceTypes, QDistinct> {
  QueryBuilder<ResourceTypes, ResourceTypes, QAfterDistinct>
      distinctByResourceTypes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }
}

extension ResourceTypesQueryProperty1
    on QueryBuilder<ResourceTypes, ResourceTypes, QProperty> {
  QueryBuilder<ResourceTypes, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ResourceTypes, List<R4ResourceType>, QAfterProperty>
      resourceTypesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }
}

extension ResourceTypesQueryProperty2<R>
    on QueryBuilder<ResourceTypes, R, QAfterProperty> {
  QueryBuilder<ResourceTypes, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ResourceTypes, (R, List<R4ResourceType>), QAfterProperty>
      resourceTypesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }
}

extension ResourceTypesQueryProperty3<R1, R2>
    on QueryBuilder<ResourceTypes, (R1, R2), QAfterProperty> {
  QueryBuilder<ResourceTypes, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ResourceTypes, (R1, R2, List<R4ResourceType>), QOperations>
      resourceTypesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }
}
