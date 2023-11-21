import 'package:fhir/r4.dart';
import 'package:isar/isar.dart';

import 'isar_resources.dart';

extension GetCollection on Isar {
  IsarCollection<int, IsarResource> resourceTypeToIsarType(
      R4ResourceType type) {
    switch (type) {
      case R4ResourceType.Account:
        return isarAccounts;
      case R4ResourceType.ActivityDefinition:
        return isarActivityDefinitions;
      case R4ResourceType.AdministrableProductDefinition:
        return isarAdministrableProductDefinitions;
      case R4ResourceType.AdverseEvent:
        return isarAdverseEvents;
      case R4ResourceType.AllergyIntolerance:
        return isarAllergyIntolerances;
      case R4ResourceType.Appointment:
        return isarAppointments;
      case R4ResourceType.AppointmentResponse:
        return isarAppointmentResponses;
      case R4ResourceType.AuditEvent:
        return isarAuditEvents;
      case R4ResourceType.Basic:
        return isarBasics;
      case R4ResourceType.Binary:
        return isarBinarys;
      case R4ResourceType.BiologicallyDerivedProduct:
        return isarBiologicallyDerivedProducts;
      case R4ResourceType.BodyStructure:
        return isarBodyStructures;
      case R4ResourceType.Bundle:
        return isarBundles;
      case R4ResourceType.CapabilityStatement:
        return isarCapabilityStatements;
      case R4ResourceType.CarePlan:
        return isarCarePlans;
      case R4ResourceType.CareTeam:
        return isarCareTeams;
      case R4ResourceType.CatalogEntry:
        return isarCatalogEntrys;
      case R4ResourceType.ChargeItem:
        return isarChargeItems;
      case R4ResourceType.ChargeItemDefinition:
        return isarChargeItemDefinitions;
      case R4ResourceType.Citation:
        return isarCitations;
      case R4ResourceType.Claim:
        return isarClaims;
      case R4ResourceType.ClaimResponse:
        return isarClaimResponses;
      case R4ResourceType.ClinicalImpression:
        return isarClinicalImpressions;
      case R4ResourceType.ClinicalUseDefinition:
        return isarClinicalUseDefinitions;
      case R4ResourceType.CodeSystem:
        return isarCodeSystems;
      case R4ResourceType.Communication:
        return isarCommunications;
      case R4ResourceType.CommunicationRequest:
        return isarCommunicationRequests;
      case R4ResourceType.CompartmentDefinition:
        return isarCompartmentDefinitions;
      case R4ResourceType.Composition:
        return isarCompositions;
      case R4ResourceType.ConceptMap:
        return isarConceptMaps;
      case R4ResourceType.Condition:
        return isarConditions;
      case R4ResourceType.Consent:
        return isarConsents;
      case R4ResourceType.Contract:
        return isarContracts;
      case R4ResourceType.Coverage:
        return isarCoverages;
      case R4ResourceType.CoverageEligibilityRequest:
        return isarCoverageEligibilityRequests;
      case R4ResourceType.CoverageEligibilityResponse:
        return isarCoverageEligibilityResponses;
      case R4ResourceType.DetectedIssue:
        return isarDetectedIssues;
      case R4ResourceType.Device:
        return isarDevices;
      case R4ResourceType.DeviceDefinition:
        return isarDeviceDefinitions;
      case R4ResourceType.DeviceMetric:
        return isarDeviceMetrics;
      case R4ResourceType.DeviceRequest:
        return isarDeviceRequests;
      case R4ResourceType.DeviceUseStatement:
        return isarDeviceUseStatements;
      case R4ResourceType.DiagnosticReport:
        return isarDiagnosticReports;
      case R4ResourceType.DocumentManifest:
        return isarDocumentManifests;
      case R4ResourceType.DocumentReference:
        return isarDocumentReferences;
      case R4ResourceType.Encounter:
        return isarEncounters;
      case R4ResourceType.Endpoint:
        return isarEndpoints;
      case R4ResourceType.EnrollmentRequest:
        return isarEnrollmentRequests;
      case R4ResourceType.EnrollmentResponse:
        return isarEnrollmentResponses;
      case R4ResourceType.EpisodeOfCare:
        return isarEpisodeOfCares;
      case R4ResourceType.EventDefinition:
        return isarEventDefinitions;
      case R4ResourceType.Evidence:
        return isarEvidences;
      case R4ResourceType.EvidenceReport:
        return isarEvidenceReports;
      case R4ResourceType.EvidenceVariable:
        return isarEvidenceVariables;
      case R4ResourceType.ExampleScenario:
        return isarExampleScenarios;
      case R4ResourceType.ExplanationOfBenefit:
        return isarExplanationOfBenefits;
      case R4ResourceType.FamilyMemberHistory:
        return isarFamilyMemberHistorys;
      case R4ResourceType.Flag:
        return isarFlags;
      case R4ResourceType.Goal:
        return isarGoals;
      case R4ResourceType.GraphDefinition:
        return isarGraphDefinitions;
      case R4ResourceType.Group:
        return isarGroups;
      case R4ResourceType.GuidanceResponse:
        return isarGuidanceResponses;
      case R4ResourceType.HealthcareService:
        return isarHealthcareServices;
      case R4ResourceType.ImagingStudy:
        return isarImagingStudys;
      case R4ResourceType.Immunization:
        return isarImmunizations;
      case R4ResourceType.ImmunizationEvaluation:
        return isarImmunizationEvaluations;
      case R4ResourceType.ImmunizationRecommendation:
        return isarImmunizationRecommendations;
      case R4ResourceType.ImplementationGuide:
        return isarImplementationGuides;
      case R4ResourceType.Ingredient:
        return isarIngredients;
      case R4ResourceType.InsurancePlan:
        return isarInsurancePlans;
      case R4ResourceType.Invoice:
        return isarInvoices;
      case R4ResourceType.Library:
        return isarLibrarys;
      case R4ResourceType.Linkage:
        return isarLinkages;
      case R4ResourceType.List:
        return isarLists;
      case R4ResourceType.Location:
        return isarLocations;
      case R4ResourceType.ManufacturedItemDefinition:
        return isarManufacturedItemDefinitions;
      case R4ResourceType.Measure:
        return isarMeasures;
      case R4ResourceType.MeasureReport:
        return isarMeasureReports;
      case R4ResourceType.Media:
        return isarMedias;
      case R4ResourceType.Medication:
        return isarMedications;
      case R4ResourceType.MedicationAdministration:
        return isarMedicationAdministrations;
      case R4ResourceType.MedicationDispense:
        return isarMedicationDispenses;
      case R4ResourceType.MedicationKnowledge:
        return isarMedicationKnowledges;
      case R4ResourceType.MedicationRequest:
        return isarMedicationRequests;
      case R4ResourceType.MedicationStatement:
        return isarMedicationStatements;
      case R4ResourceType.MedicinalProductDefinition:
        return isarMedicinalProductDefinitions;
      case R4ResourceType.MessageDefinition:
        return isarMessageDefinitions;
      case R4ResourceType.MessageHeader:
        return isarMessageHeaders;
      case R4ResourceType.MolecularSequence:
        return isarMolecularSequences;
      case R4ResourceType.NamingSystem:
        return isarNamingSystems;
      case R4ResourceType.NutritionOrder:
        return isarNutritionOrders;
      case R4ResourceType.NutritionProduct:
        return isarNutritionProducts;
      case R4ResourceType.Observation:
        return isarObservations;
      case R4ResourceType.ObservationDefinition:
        return isarObservationDefinitions;
      case R4ResourceType.OperationDefinition:
        return isarOperationDefinitions;
      case R4ResourceType.OperationOutcome:
        return isarOperationOutcomes;
      case R4ResourceType.Organization:
        return isarOrganizations;
      case R4ResourceType.OrganizationAffiliation:
        return isarOrganizationAffiliations;
      case R4ResourceType.PackagedProductDefinition:
        return isarPackagedProductDefinitions;
      case R4ResourceType.Parameters:
        return isarParameters;
      case R4ResourceType.Patient:
        return isarPatients;
      case R4ResourceType.PaymentNotice:
        return isarPaymentNotices;
      case R4ResourceType.PaymentReconciliation:
        return isarPaymentReconciliations;
      case R4ResourceType.Person:
        return isarPersons;
      case R4ResourceType.PlanDefinition:
        return isarPlanDefinitions;
      case R4ResourceType.Practitioner:
        return isarPractitioners;
      case R4ResourceType.PractitionerRole:
        return isarPractitionerRoles;
      case R4ResourceType.Procedure:
        return isarProcedures;
      case R4ResourceType.Provenance:
        return isarProvenances;
      case R4ResourceType.Questionnaire:
        return isarQuestionnaires;
      case R4ResourceType.QuestionnaireResponse:
        return isarQuestionnaireResponses;
      case R4ResourceType.RegulatedAuthorization:
        return isarRegulatedAuthorizations;
      case R4ResourceType.RelatedPerson:
        return isarRelatedPersons;
      case R4ResourceType.RequestGroup:
        return isarRequestGroups;
      case R4ResourceType.ResearchDefinition:
        return isarResearchDefinitions;
      case R4ResourceType.ResearchElementDefinition:
        return isarResearchElementDefinitions;
      case R4ResourceType.ResearchStudy:
        return isarResearchStudys;
      case R4ResourceType.ResearchSubject:
        return isarResearchSubjects;
      case R4ResourceType.RiskAssessment:
        return isarRiskAssessments;
      case R4ResourceType.Schedule:
        return isarSchedules;
      case R4ResourceType.SearchParameter:
        return isarSearchParameters;
      case R4ResourceType.ServiceRequest:
        return isarServiceRequests;
      case R4ResourceType.Slot:
        return isarSlots;
      case R4ResourceType.Specimen:
        return isarSpecimens;
      case R4ResourceType.SpecimenDefinition:
        return isarSpecimenDefinitions;
      case R4ResourceType.StructureDefinition:
        return isarStructureDefinitions;
      case R4ResourceType.StructureMap:
        return isarStructureMaps;
      case R4ResourceType.Subscription:
        return isarSubscriptions;
      case R4ResourceType.SubscriptionStatus:
        return isarSubscriptionStatus;
      case R4ResourceType.SubscriptionTopic:
        return isarSubscriptionTopics;
      case R4ResourceType.Substance:
        return isarSubstances;
      case R4ResourceType.SubstanceDefinition:
        return isarSubstanceDefinitions;
      case R4ResourceType.SupplyDelivery:
        return isarSupplyDeliverys;
      case R4ResourceType.SupplyRequest:
        return isarSupplyRequests;
      case R4ResourceType.Task:
        return isarTasks;
      case R4ResourceType.TerminologyCapabilities:
        return isarTerminologyCapabilities;
      case R4ResourceType.TestReport:
        return isarTestReports;
      case R4ResourceType.TestScript:
        return isarTestScripts;
      case R4ResourceType.ValueSet:
        return isarValueSets;
      case R4ResourceType.VerificationResult:
        return isarVerificationResults;
      case R4ResourceType.VisionPrescription:
        return isarVisionPrescriptions;
    }
  }
}