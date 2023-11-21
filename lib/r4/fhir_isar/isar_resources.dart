import 'package:fhir/r4.dart';
import 'package:isar/isar.dart';

import 'fhir_isar.dart';

part 'isar_resources.g.dart';

class IsarResource {
  IsarResource({required this.id, required this.resource});
  IsarResource.fromFhir(Resource resource) {
    final Resource newResource = resourceWithDbId(resource);
    id = newResource.dbId!;
    fhirId = newResource.fhirId!;
    this.resource = newResource.toJson();
  }
  IsarResource.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> newMap = mapWithDbId(map);
    id = newMap['dbId'] as int;
    fhirId = newMap['fhirId'] as String;
    resource = newMap;
  }
  @Id()
  late int id;

  @Index()
  late String fhirId;
  late Map<String, dynamic> resource;

  Resource toFhir() => Resource.fromJson(resource);
}

@collection
class HistoryResource extends IsarResource {
  HistoryResource({required super.id, required super.resource});
  HistoryResource.fromFhir(super.resource) : super.fromFhir();
  HistoryResource.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarAccount extends IsarResource {
  IsarAccount({required super.id, required super.resource});
  IsarAccount.fromFhir(super.resource) : super.fromFhir();
  IsarAccount.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarActivityDefinition extends IsarResource {
  IsarActivityDefinition({required super.id, required super.resource});
  IsarActivityDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarActivityDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarAdministrableProductDefinition extends IsarResource {
  IsarAdministrableProductDefinition(
      {required super.id, required super.resource});
  IsarAdministrableProductDefinition.fromFhir(super.resource)
      : super.fromFhir();
  IsarAdministrableProductDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarAdverseEvent extends IsarResource {
  IsarAdverseEvent({required super.id, required super.resource});
  IsarAdverseEvent.fromFhir(super.resource) : super.fromFhir();
  IsarAdverseEvent.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarAllergyIntolerance extends IsarResource {
  IsarAllergyIntolerance({required super.id, required super.resource});
  IsarAllergyIntolerance.fromFhir(super.resource) : super.fromFhir();
  IsarAllergyIntolerance.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarAppointment extends IsarResource {
  IsarAppointment({required super.id, required super.resource});
  IsarAppointment.fromFhir(super.resource) : super.fromFhir();
  IsarAppointment.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarAppointmentResponse extends IsarResource {
  IsarAppointmentResponse({required super.id, required super.resource});
  IsarAppointmentResponse.fromFhir(super.resource) : super.fromFhir();
  IsarAppointmentResponse.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarAuditEvent extends IsarResource {
  IsarAuditEvent({required super.id, required super.resource});
  IsarAuditEvent.fromFhir(super.resource) : super.fromFhir();
  IsarAuditEvent.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarBasic extends IsarResource {
  IsarBasic({required super.id, required super.resource});
  IsarBasic.fromFhir(super.resource) : super.fromFhir();
  IsarBasic.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarBinary extends IsarResource {
  IsarBinary({required super.id, required super.resource});
  IsarBinary.fromFhir(super.resource) : super.fromFhir();
  IsarBinary.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarBiologicallyDerivedProduct extends IsarResource {
  IsarBiologicallyDerivedProduct({required super.id, required super.resource});
  IsarBiologicallyDerivedProduct.fromFhir(super.resource) : super.fromFhir();
  IsarBiologicallyDerivedProduct.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarBodyStructure extends IsarResource {
  IsarBodyStructure({required super.id, required super.resource});
  IsarBodyStructure.fromFhir(super.resource) : super.fromFhir();
  IsarBodyStructure.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarBundle extends IsarResource {
  IsarBundle({required super.id, required super.resource});
  IsarBundle.fromFhir(super.resource) : super.fromFhir();
  IsarBundle.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCapabilityStatement extends IsarResource {
  IsarCapabilityStatement({required super.id, required super.resource});
  IsarCapabilityStatement.fromFhir(super.resource) : super.fromFhir();
  IsarCapabilityStatement.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCarePlan extends IsarResource {
  IsarCarePlan({required super.id, required super.resource});
  IsarCarePlan.fromFhir(super.resource) : super.fromFhir();
  IsarCarePlan.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCareTeam extends IsarResource {
  IsarCareTeam({required super.id, required super.resource});
  IsarCareTeam.fromFhir(super.resource) : super.fromFhir();
  IsarCareTeam.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCatalogEntry extends IsarResource {
  IsarCatalogEntry({required super.id, required super.resource});
  IsarCatalogEntry.fromFhir(super.resource) : super.fromFhir();
  IsarCatalogEntry.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarChargeItem extends IsarResource {
  IsarChargeItem({required super.id, required super.resource});
  IsarChargeItem.fromFhir(super.resource) : super.fromFhir();
  IsarChargeItem.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarChargeItemDefinition extends IsarResource {
  IsarChargeItemDefinition({required super.id, required super.resource});
  IsarChargeItemDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarChargeItemDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCitation extends IsarResource {
  IsarCitation({required super.id, required super.resource});
  IsarCitation.fromFhir(super.resource) : super.fromFhir();
  IsarCitation.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarClaim extends IsarResource {
  IsarClaim({required super.id, required super.resource});
  IsarClaim.fromFhir(super.resource) : super.fromFhir();
  IsarClaim.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarClaimResponse extends IsarResource {
  IsarClaimResponse({required super.id, required super.resource});
  IsarClaimResponse.fromFhir(super.resource) : super.fromFhir();
  IsarClaimResponse.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarClinicalImpression extends IsarResource {
  IsarClinicalImpression({required super.id, required super.resource});
  IsarClinicalImpression.fromFhir(super.resource) : super.fromFhir();
  IsarClinicalImpression.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarClinicalUseDefinition extends IsarResource {
  IsarClinicalUseDefinition({required super.id, required super.resource});
  IsarClinicalUseDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarClinicalUseDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCodeSystem extends IsarResource {
  IsarCodeSystem({required super.id, required super.resource});
  IsarCodeSystem.fromFhir(super.resource) : super.fromFhir();
  IsarCodeSystem.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCommunication extends IsarResource {
  IsarCommunication({required super.id, required super.resource});
  IsarCommunication.fromFhir(super.resource) : super.fromFhir();
  IsarCommunication.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCommunicationRequest extends IsarResource {
  IsarCommunicationRequest({required super.id, required super.resource});
  IsarCommunicationRequest.fromFhir(super.resource) : super.fromFhir();
  IsarCommunicationRequest.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCompartmentDefinition extends IsarResource {
  IsarCompartmentDefinition({required super.id, required super.resource});
  IsarCompartmentDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarCompartmentDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarComposition extends IsarResource {
  IsarComposition({required super.id, required super.resource});
  IsarComposition.fromFhir(super.resource) : super.fromFhir();
  IsarComposition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarConceptMap extends IsarResource {
  IsarConceptMap({required super.id, required super.resource});
  IsarConceptMap.fromFhir(super.resource) : super.fromFhir();
  IsarConceptMap.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCondition extends IsarResource {
  IsarCondition({required super.id, required super.resource});
  IsarCondition.fromFhir(super.resource) : super.fromFhir();
  IsarCondition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarConsent extends IsarResource {
  IsarConsent({required super.id, required super.resource});
  IsarConsent.fromFhir(super.resource) : super.fromFhir();
  IsarConsent.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarContract extends IsarResource {
  IsarContract({required super.id, required super.resource});
  IsarContract.fromFhir(super.resource) : super.fromFhir();
  IsarContract.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCoverage extends IsarResource {
  IsarCoverage({required super.id, required super.resource});
  IsarCoverage.fromFhir(super.resource) : super.fromFhir();
  IsarCoverage.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCoverageEligibilityRequest extends IsarResource {
  IsarCoverageEligibilityRequest({required super.id, required super.resource});
  IsarCoverageEligibilityRequest.fromFhir(super.resource) : super.fromFhir();
  IsarCoverageEligibilityRequest.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarCoverageEligibilityResponse extends IsarResource {
  IsarCoverageEligibilityResponse({required super.id, required super.resource});
  IsarCoverageEligibilityResponse.fromFhir(super.resource) : super.fromFhir();
  IsarCoverageEligibilityResponse.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDetectedIssue extends IsarResource {
  IsarDetectedIssue({required super.id, required super.resource});
  IsarDetectedIssue.fromFhir(super.resource) : super.fromFhir();
  IsarDetectedIssue.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDevice extends IsarResource {
  IsarDevice({required super.id, required super.resource});
  IsarDevice.fromFhir(super.resource) : super.fromFhir();
  IsarDevice.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDeviceDefinition extends IsarResource {
  IsarDeviceDefinition({required super.id, required super.resource});
  IsarDeviceDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarDeviceDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDeviceMetric extends IsarResource {
  IsarDeviceMetric({required super.id, required super.resource});
  IsarDeviceMetric.fromFhir(super.resource) : super.fromFhir();
  IsarDeviceMetric.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDeviceRequest extends IsarResource {
  IsarDeviceRequest({required super.id, required super.resource});
  IsarDeviceRequest.fromFhir(super.resource) : super.fromFhir();
  IsarDeviceRequest.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDeviceUseStatement extends IsarResource {
  IsarDeviceUseStatement({required super.id, required super.resource});
  IsarDeviceUseStatement.fromFhir(super.resource) : super.fromFhir();
  IsarDeviceUseStatement.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDiagnosticReport extends IsarResource {
  IsarDiagnosticReport({required super.id, required super.resource});
  IsarDiagnosticReport.fromFhir(super.resource) : super.fromFhir();
  IsarDiagnosticReport.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDocumentManifest extends IsarResource {
  IsarDocumentManifest({required super.id, required super.resource});
  IsarDocumentManifest.fromFhir(super.resource) : super.fromFhir();
  IsarDocumentManifest.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarDocumentReference extends IsarResource {
  IsarDocumentReference({required super.id, required super.resource});
  IsarDocumentReference.fromFhir(super.resource) : super.fromFhir();
  IsarDocumentReference.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEncounter extends IsarResource {
  IsarEncounter({required super.id, required super.resource});
  IsarEncounter.fromFhir(super.resource) : super.fromFhir();
  IsarEncounter.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEndpoint extends IsarResource {
  IsarEndpoint({required super.id, required super.resource});
  IsarEndpoint.fromFhir(super.resource) : super.fromFhir();
  IsarEndpoint.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEnrollmentRequest extends IsarResource {
  IsarEnrollmentRequest({required super.id, required super.resource});
  IsarEnrollmentRequest.fromFhir(super.resource) : super.fromFhir();
  IsarEnrollmentRequest.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEnrollmentResponse extends IsarResource {
  IsarEnrollmentResponse({required super.id, required super.resource});
  IsarEnrollmentResponse.fromFhir(super.resource) : super.fromFhir();
  IsarEnrollmentResponse.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEpisodeOfCare extends IsarResource {
  IsarEpisodeOfCare({required super.id, required super.resource});
  IsarEpisodeOfCare.fromFhir(super.resource) : super.fromFhir();
  IsarEpisodeOfCare.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEventDefinition extends IsarResource {
  IsarEventDefinition({required super.id, required super.resource});
  IsarEventDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarEventDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEvidence extends IsarResource {
  IsarEvidence({required super.id, required super.resource});
  IsarEvidence.fromFhir(super.resource) : super.fromFhir();
  IsarEvidence.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEvidenceReport extends IsarResource {
  IsarEvidenceReport({required super.id, required super.resource});
  IsarEvidenceReport.fromFhir(super.resource) : super.fromFhir();
  IsarEvidenceReport.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarEvidenceVariable extends IsarResource {
  IsarEvidenceVariable({required super.id, required super.resource});
  IsarEvidenceVariable.fromFhir(super.resource) : super.fromFhir();
  IsarEvidenceVariable.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarExampleScenario extends IsarResource {
  IsarExampleScenario({required super.id, required super.resource});
  IsarExampleScenario.fromFhir(super.resource) : super.fromFhir();
  IsarExampleScenario.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarExplanationOfBenefit extends IsarResource {
  IsarExplanationOfBenefit({required super.id, required super.resource});
  IsarExplanationOfBenefit.fromFhir(super.resource) : super.fromFhir();
  IsarExplanationOfBenefit.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarFamilyMemberHistory extends IsarResource {
  IsarFamilyMemberHistory({required super.id, required super.resource});
  IsarFamilyMemberHistory.fromFhir(super.resource) : super.fromFhir();
  IsarFamilyMemberHistory.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarFlag extends IsarResource {
  IsarFlag({required super.id, required super.resource});
  IsarFlag.fromFhir(super.resource) : super.fromFhir();
  IsarFlag.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarGoal extends IsarResource {
  IsarGoal({required super.id, required super.resource});
  IsarGoal.fromFhir(super.resource) : super.fromFhir();
  IsarGoal.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarGraphDefinition extends IsarResource {
  IsarGraphDefinition({required super.id, required super.resource});
  IsarGraphDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarGraphDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarGroup extends IsarResource {
  IsarGroup({required super.id, required super.resource});
  IsarGroup.fromFhir(super.resource) : super.fromFhir();
  IsarGroup.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarGuidanceResponse extends IsarResource {
  IsarGuidanceResponse({required super.id, required super.resource});
  IsarGuidanceResponse.fromFhir(super.resource) : super.fromFhir();
  IsarGuidanceResponse.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarHealthcareService extends IsarResource {
  IsarHealthcareService({required super.id, required super.resource});
  IsarHealthcareService.fromFhir(super.resource) : super.fromFhir();
  IsarHealthcareService.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarImagingStudy extends IsarResource {
  IsarImagingStudy({required super.id, required super.resource});
  IsarImagingStudy.fromFhir(super.resource) : super.fromFhir();
  IsarImagingStudy.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarImmunization extends IsarResource {
  IsarImmunization({required super.id, required super.resource});
  IsarImmunization.fromFhir(super.resource) : super.fromFhir();
  IsarImmunization.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarImmunizationEvaluation extends IsarResource {
  IsarImmunizationEvaluation({required super.id, required super.resource});
  IsarImmunizationEvaluation.fromFhir(super.resource) : super.fromFhir();
  IsarImmunizationEvaluation.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarImmunizationRecommendation extends IsarResource {
  IsarImmunizationRecommendation({required super.id, required super.resource});
  IsarImmunizationRecommendation.fromFhir(super.resource) : super.fromFhir();
  IsarImmunizationRecommendation.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarImplementationGuide extends IsarResource {
  IsarImplementationGuide({required super.id, required super.resource});
  IsarImplementationGuide.fromFhir(super.resource) : super.fromFhir();
  IsarImplementationGuide.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarIngredient extends IsarResource {
  IsarIngredient({required super.id, required super.resource});
  IsarIngredient.fromFhir(super.resource) : super.fromFhir();
  IsarIngredient.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarInsurancePlan extends IsarResource {
  IsarInsurancePlan({required super.id, required super.resource});
  IsarInsurancePlan.fromFhir(super.resource) : super.fromFhir();
  IsarInsurancePlan.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarInvoice extends IsarResource {
  IsarInvoice({required super.id, required super.resource});
  IsarInvoice.fromFhir(super.resource) : super.fromFhir();
  IsarInvoice.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarLibrary extends IsarResource {
  IsarLibrary({required super.id, required super.resource});
  IsarLibrary.fromFhir(super.resource) : super.fromFhir();
  IsarLibrary.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarLinkage extends IsarResource {
  IsarLinkage({required super.id, required super.resource});
  IsarLinkage.fromFhir(super.resource) : super.fromFhir();
  IsarLinkage.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarList extends IsarResource {
  IsarList({required super.id, required super.resource});
  IsarList.fromFhir(super.resource) : super.fromFhir();
  IsarList.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarLocation extends IsarResource {
  IsarLocation({required super.id, required super.resource});
  IsarLocation.fromFhir(super.resource) : super.fromFhir();
  IsarLocation.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarManufacturedItemDefinition extends IsarResource {
  IsarManufacturedItemDefinition({required super.id, required super.resource});
  IsarManufacturedItemDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarManufacturedItemDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMeasure extends IsarResource {
  IsarMeasure({required super.id, required super.resource});
  IsarMeasure.fromFhir(super.resource) : super.fromFhir();
  IsarMeasure.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMeasureReport extends IsarResource {
  IsarMeasureReport({required super.id, required super.resource});
  IsarMeasureReport.fromFhir(super.resource) : super.fromFhir();
  IsarMeasureReport.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMedia extends IsarResource {
  IsarMedia({required super.id, required super.resource});
  IsarMedia.fromFhir(super.resource) : super.fromFhir();
  IsarMedia.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMedication extends IsarResource {
  IsarMedication({required super.id, required super.resource});
  IsarMedication.fromFhir(super.resource) : super.fromFhir();
  IsarMedication.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMedicationAdministration extends IsarResource {
  IsarMedicationAdministration({required super.id, required super.resource});
  IsarMedicationAdministration.fromFhir(super.resource) : super.fromFhir();
  IsarMedicationAdministration.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMedicationDispense extends IsarResource {
  IsarMedicationDispense({required super.id, required super.resource});
  IsarMedicationDispense.fromFhir(super.resource) : super.fromFhir();
  IsarMedicationDispense.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMedicationKnowledge extends IsarResource {
  IsarMedicationKnowledge({required super.id, required super.resource});
  IsarMedicationKnowledge.fromFhir(super.resource) : super.fromFhir();
  IsarMedicationKnowledge.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMedicationRequest extends IsarResource {
  IsarMedicationRequest({required super.id, required super.resource});
  IsarMedicationRequest.fromFhir(super.resource) : super.fromFhir();
  IsarMedicationRequest.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMedicationStatement extends IsarResource {
  IsarMedicationStatement({required super.id, required super.resource});
  IsarMedicationStatement.fromFhir(super.resource) : super.fromFhir();
  IsarMedicationStatement.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMedicinalProductDefinition extends IsarResource {
  IsarMedicinalProductDefinition({required super.id, required super.resource});
  IsarMedicinalProductDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarMedicinalProductDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMessageDefinition extends IsarResource {
  IsarMessageDefinition({required super.id, required super.resource});
  IsarMessageDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarMessageDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMessageHeader extends IsarResource {
  IsarMessageHeader({required super.id, required super.resource});
  IsarMessageHeader.fromFhir(super.resource) : super.fromFhir();
  IsarMessageHeader.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarMolecularSequence extends IsarResource {
  IsarMolecularSequence({required super.id, required super.resource});
  IsarMolecularSequence.fromFhir(super.resource) : super.fromFhir();
  IsarMolecularSequence.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarNamingSystem extends IsarResource {
  IsarNamingSystem({required super.id, required super.resource});
  IsarNamingSystem.fromFhir(super.resource) : super.fromFhir();
  IsarNamingSystem.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarNutritionOrder extends IsarResource {
  IsarNutritionOrder({required super.id, required super.resource});
  IsarNutritionOrder.fromFhir(super.resource) : super.fromFhir();
  IsarNutritionOrder.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarNutritionProduct extends IsarResource {
  IsarNutritionProduct({required super.id, required super.resource});
  IsarNutritionProduct.fromFhir(super.resource) : super.fromFhir();
  IsarNutritionProduct.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarObservation extends IsarResource {
  IsarObservation({required super.id, required super.resource});
  IsarObservation.fromFhir(super.resource) : super.fromFhir();
  IsarObservation.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarObservationDefinition extends IsarResource {
  IsarObservationDefinition({required super.id, required super.resource});
  IsarObservationDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarObservationDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarOperationDefinition extends IsarResource {
  IsarOperationDefinition({required super.id, required super.resource});
  IsarOperationDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarOperationDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarOperationOutcome extends IsarResource {
  IsarOperationOutcome({required super.id, required super.resource});
  IsarOperationOutcome.fromFhir(super.resource) : super.fromFhir();
  IsarOperationOutcome.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarOrganization extends IsarResource {
  IsarOrganization({required super.id, required super.resource});
  IsarOrganization.fromFhir(super.resource) : super.fromFhir();
  IsarOrganization.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarOrganizationAffiliation extends IsarResource {
  IsarOrganizationAffiliation({required super.id, required super.resource});
  IsarOrganizationAffiliation.fromFhir(super.resource) : super.fromFhir();
  IsarOrganizationAffiliation.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarPackagedProductDefinition extends IsarResource {
  IsarPackagedProductDefinition({required super.id, required super.resource});
  IsarPackagedProductDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarPackagedProductDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarParameters extends IsarResource {
  IsarParameters({required super.id, required super.resource});
  IsarParameters.fromFhir(super.resource) : super.fromFhir();
  IsarParameters.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarPatient extends IsarResource {
  IsarPatient({required super.id, required super.resource});
  IsarPatient.fromFhir(super.resource) : super.fromFhir();
  IsarPatient.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarPaymentNotice extends IsarResource {
  IsarPaymentNotice({required super.id, required super.resource});
  IsarPaymentNotice.fromFhir(super.resource) : super.fromFhir();
  IsarPaymentNotice.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarPaymentReconciliation extends IsarResource {
  IsarPaymentReconciliation({required super.id, required super.resource});
  IsarPaymentReconciliation.fromFhir(super.resource) : super.fromFhir();
  IsarPaymentReconciliation.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarPerson extends IsarResource {
  IsarPerson({required super.id, required super.resource});
  IsarPerson.fromFhir(super.resource) : super.fromFhir();
  IsarPerson.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarPlanDefinition extends IsarResource {
  IsarPlanDefinition({required super.id, required super.resource});
  IsarPlanDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarPlanDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarPractitioner extends IsarResource {
  IsarPractitioner({required super.id, required super.resource});
  IsarPractitioner.fromFhir(super.resource) : super.fromFhir();
  IsarPractitioner.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarPractitionerRole extends IsarResource {
  IsarPractitionerRole({required super.id, required super.resource});
  IsarPractitionerRole.fromFhir(super.resource) : super.fromFhir();
  IsarPractitionerRole.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarProcedure extends IsarResource {
  IsarProcedure({required super.id, required super.resource});
  IsarProcedure.fromFhir(super.resource) : super.fromFhir();
  IsarProcedure.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarProvenance extends IsarResource {
  IsarProvenance({required super.id, required super.resource});
  IsarProvenance.fromFhir(super.resource) : super.fromFhir();
  IsarProvenance.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarQuestionnaire extends IsarResource {
  IsarQuestionnaire({required super.id, required super.resource});
  IsarQuestionnaire.fromFhir(super.resource) : super.fromFhir();
  IsarQuestionnaire.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarQuestionnaireResponse extends IsarResource {
  IsarQuestionnaireResponse({required super.id, required super.resource});
  IsarQuestionnaireResponse.fromFhir(super.resource) : super.fromFhir();
  IsarQuestionnaireResponse.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarRegulatedAuthorization extends IsarResource {
  IsarRegulatedAuthorization({required super.id, required super.resource});
  IsarRegulatedAuthorization.fromFhir(super.resource) : super.fromFhir();
  IsarRegulatedAuthorization.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarRelatedPerson extends IsarResource {
  IsarRelatedPerson({required super.id, required super.resource});
  IsarRelatedPerson.fromFhir(super.resource) : super.fromFhir();
  IsarRelatedPerson.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarRequestGroup extends IsarResource {
  IsarRequestGroup({required super.id, required super.resource});
  IsarRequestGroup.fromFhir(super.resource) : super.fromFhir();
  IsarRequestGroup.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarResearchDefinition extends IsarResource {
  IsarResearchDefinition({required super.id, required super.resource});
  IsarResearchDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarResearchDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarResearchElementDefinition extends IsarResource {
  IsarResearchElementDefinition({required super.id, required super.resource});
  IsarResearchElementDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarResearchElementDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarResearchStudy extends IsarResource {
  IsarResearchStudy({required super.id, required super.resource});
  IsarResearchStudy.fromFhir(super.resource) : super.fromFhir();
  IsarResearchStudy.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarResearchSubject extends IsarResource {
  IsarResearchSubject({required super.id, required super.resource});
  IsarResearchSubject.fromFhir(super.resource) : super.fromFhir();
  IsarResearchSubject.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarRiskAssessment extends IsarResource {
  IsarRiskAssessment({required super.id, required super.resource});
  IsarRiskAssessment.fromFhir(super.resource) : super.fromFhir();
  IsarRiskAssessment.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSchedule extends IsarResource {
  IsarSchedule({required super.id, required super.resource});
  IsarSchedule.fromFhir(super.resource) : super.fromFhir();
  IsarSchedule.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSearchParameter extends IsarResource {
  IsarSearchParameter({required super.id, required super.resource});
  IsarSearchParameter.fromFhir(super.resource) : super.fromFhir();
  IsarSearchParameter.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarServiceRequest extends IsarResource {
  IsarServiceRequest({required super.id, required super.resource});
  IsarServiceRequest.fromFhir(super.resource) : super.fromFhir();
  IsarServiceRequest.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSlot extends IsarResource {
  IsarSlot({required super.id, required super.resource});
  IsarSlot.fromFhir(super.resource) : super.fromFhir();
  IsarSlot.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSpecimen extends IsarResource {
  IsarSpecimen({required super.id, required super.resource});
  IsarSpecimen.fromFhir(super.resource) : super.fromFhir();
  IsarSpecimen.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSpecimenDefinition extends IsarResource {
  IsarSpecimenDefinition({required super.id, required super.resource});
  IsarSpecimenDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarSpecimenDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarStructureDefinition extends IsarResource {
  IsarStructureDefinition({required super.id, required super.resource});
  IsarStructureDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarStructureDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarStructureMap extends IsarResource {
  IsarStructureMap({required super.id, required super.resource});
  IsarStructureMap.fromFhir(super.resource) : super.fromFhir();
  IsarStructureMap.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSubscription extends IsarResource {
  IsarSubscription({required super.id, required super.resource});
  IsarSubscription.fromFhir(super.resource) : super.fromFhir();
  IsarSubscription.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSubscriptionStatus extends IsarResource {
  IsarSubscriptionStatus({required super.id, required super.resource});
  IsarSubscriptionStatus.fromFhir(super.resource) : super.fromFhir();
  IsarSubscriptionStatus.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSubscriptionTopic extends IsarResource {
  IsarSubscriptionTopic({required super.id, required super.resource});
  IsarSubscriptionTopic.fromFhir(super.resource) : super.fromFhir();
  IsarSubscriptionTopic.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSubstance extends IsarResource {
  IsarSubstance({required super.id, required super.resource});
  IsarSubstance.fromFhir(super.resource) : super.fromFhir();
  IsarSubstance.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSubstanceDefinition extends IsarResource {
  IsarSubstanceDefinition({required super.id, required super.resource});
  IsarSubstanceDefinition.fromFhir(super.resource) : super.fromFhir();
  IsarSubstanceDefinition.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSupplyDelivery extends IsarResource {
  IsarSupplyDelivery({required super.id, required super.resource});
  IsarSupplyDelivery.fromFhir(super.resource) : super.fromFhir();
  IsarSupplyDelivery.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarSupplyRequest extends IsarResource {
  IsarSupplyRequest({required super.id, required super.resource});
  IsarSupplyRequest.fromFhir(super.resource) : super.fromFhir();
  IsarSupplyRequest.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarTask extends IsarResource {
  IsarTask({required super.id, required super.resource});
  IsarTask.fromFhir(super.resource) : super.fromFhir();
  IsarTask.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarTerminologyCapabilities extends IsarResource {
  IsarTerminologyCapabilities({required super.id, required super.resource});
  IsarTerminologyCapabilities.fromFhir(super.resource) : super.fromFhir();
  IsarTerminologyCapabilities.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarTestReport extends IsarResource {
  IsarTestReport({required super.id, required super.resource});
  IsarTestReport.fromFhir(super.resource) : super.fromFhir();
  IsarTestReport.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarTestScript extends IsarResource {
  IsarTestScript({required super.id, required super.resource});
  IsarTestScript.fromFhir(super.resource) : super.fromFhir();
  IsarTestScript.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarValueSet extends IsarResource {
  IsarValueSet({required super.id, required super.resource});
  IsarValueSet.fromFhir(super.resource) : super.fromFhir();
  IsarValueSet.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarVerificationResult extends IsarResource {
  IsarVerificationResult({required super.id, required super.resource});
  IsarVerificationResult.fromFhir(super.resource) : super.fromFhir();
  IsarVerificationResult.fromMap(super.resource) : super.fromMap();
}

@collection
class IsarVisionPrescription extends IsarResource {
  IsarVisionPrescription({required super.id, required super.resource});
  IsarVisionPrescription.fromFhir(super.resource) : super.fromFhir();
  IsarVisionPrescription.fromMap(super.resource) : super.fromMap();
}
