import 'package:fhir/r4.dart';
import 'package:isar/isar.dart';

import 'fast_hash.dart';

part 'resources.g.dart';

@collection
class IsarAccount {
  IsarAccount({required this.id, required this.account});
  IsarAccount.fromFhir(Account account) {
    final Resource newResource = withDbId(account);
    id = newResource.dbId!;
    this.account = account.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> account;
}

@collection
class IsarActivityDefinition {
  IsarActivityDefinition({required this.id, required this.activityDefinition});
  IsarActivityDefinition.fromFhir(ActivityDefinition activityDefinition) {
    final Resource newResource = withDbId(activityDefinition);
    id = activityDefinition.dbId!;
    this.activityDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> activityDefinition;
}

@collection
class IsarAdministrableProductDefinition {
  IsarAdministrableProductDefinition(
      {required this.id, required this.administrableProductDefinition});
  IsarAdministrableProductDefinition.fromFhir(
      AdministrableProductDefinition administrableProductDefinition) {
    final Resource newResource = withDbId(administrableProductDefinition);
    id = administrableProductDefinition.dbId!;
    this.administrableProductDefinition = newResource.toJson();
  }

  @Id()
  late int id;
  late Map<String, dynamic> administrableProductDefinition;
}

@collection
class IsarAdverseEvent {
  IsarAdverseEvent({required this.id, required this.adverseEvent});
  IsarAdverseEvent.fromFhir(AdverseEvent adverseEvent) {
    final Resource newResource = withDbId(adverseEvent);
    id = adverseEvent.dbId!;
    this.adverseEvent = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> adverseEvent;
}

@collection
class IsarAllergyIntolerance {
  IsarAllergyIntolerance({required this.id, required this.allergyIntolerance});
  IsarAllergyIntolerance.fromFhir(AllergyIntolerance allergyIntolerance) {
    final Resource newResource = withDbId(allergyIntolerance);
    id = allergyIntolerance.dbId!;
    this.allergyIntolerance = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> allergyIntolerance;
}

@collection
class IsarAppointment {
  IsarAppointment({required this.id, required this.appointment});
  IsarAppointment.fromFhir(Appointment appointment) {
    final Resource newResource = withDbId(appointment);
    id = appointment.dbId!;
    this.appointment = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> appointment;
}

@collection
class IsarAppointmentResponse {
  IsarAppointmentResponse(
      {required this.id, required this.appointmentResponse});
  IsarAppointmentResponse.fromFhir(AppointmentResponse appointmentResponse) {
    final Resource newResource = withDbId(appointmentResponse);
    id = appointmentResponse.dbId!;
    this.appointmentResponse = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> appointmentResponse;
}

@collection
class IsarAuditEvent {
  IsarAuditEvent({required this.id, required this.auditEvent});
  IsarAuditEvent.fromFhir(AuditEvent auditEvent) {
    final Resource newResource = withDbId(auditEvent);
    id = auditEvent.dbId!;
    this.auditEvent = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> auditEvent;
}

@collection
class IsarBasic {
  IsarBasic({required this.id, required this.basic});
  IsarBasic.fromFhir(Basic basic) {
    final Resource newResource = withDbId(basic);
    id = basic.dbId!;
    this.basic = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> basic;
}

@collection
class IsarBinary {
  IsarBinary({required this.id, required this.binary});
  IsarBinary.fromFhir(Binary binary) {
    final Resource newResource = withDbId(binary);
    id = binary.dbId!;
    this.binary = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> binary;
}

@collection
class IsarBiologicallyDerivedProduct {
  IsarBiologicallyDerivedProduct(
      {required this.id, required this.biologicallyDerivedProduct});
  IsarBiologicallyDerivedProduct.fromFhir(
      BiologicallyDerivedProduct biologicallyDerivedProduct) {
    final Resource newResource = withDbId(biologicallyDerivedProduct);
    id = biologicallyDerivedProduct.dbId!;
    this.biologicallyDerivedProduct = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> biologicallyDerivedProduct;
}

@collection
class IsarBodyStructure {
  IsarBodyStructure({required this.id, required this.bodyStructure});
  IsarBodyStructure.fromFhir(BodyStructure bodyStructure) {
    final Resource newResource = withDbId(bodyStructure);
    id = bodyStructure.dbId!;
    this.bodyStructure = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> bodyStructure;
}

@collection
class IsarBundle {
  IsarBundle({required this.id, required this.bundle});
  IsarBundle.fromFhir(Bundle bundle) {
    final Resource newResource = withDbId(bundle);
    id = bundle.dbId!;
    this.bundle = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> bundle;
}

@collection
class IsarCapabilityStatement {
  IsarCapabilityStatement(
      {required this.id, required this.capabilityStatement});
  IsarCapabilityStatement.fromFhir(CapabilityStatement capabilityStatement) {
    final Resource newResource = withDbId(capabilityStatement);
    id = capabilityStatement.dbId!;
    this.capabilityStatement = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> capabilityStatement;
}

@collection
class IsarCarePlan {
  IsarCarePlan({required this.id, required this.carePlan});
  IsarCarePlan.fromFhir(CarePlan carePlan) {
    final Resource newResource = withDbId(carePlan);
    id = carePlan.dbId!;
    this.carePlan = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> carePlan;
}

@collection
class IsarCareTeam {
  IsarCareTeam({required this.id, required this.careTeam});
  IsarCareTeam.fromFhir(CareTeam careTeam) {
    final Resource newResource = withDbId(careTeam);
    id = careTeam.dbId!;
    this.careTeam = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> careTeam;
}

@collection
class IsarCatalogEntry {
  IsarCatalogEntry({required this.id, required this.catalogEntry});
  IsarCatalogEntry.fromFhir(CatalogEntry catalogEntry) {
    final Resource newResource = withDbId(catalogEntry);
    id = catalogEntry.dbId!;
    this.catalogEntry = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> catalogEntry;
}

@collection
class IsarChargeItem {
  IsarChargeItem({required this.id, required this.chargeItem});
  IsarChargeItem.fromFhir(ChargeItem chargeItem) {
    final Resource newResource = withDbId(chargeItem);
    id = chargeItem.dbId!;
    this.chargeItem = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> chargeItem;
}

@collection
class IsarChargeItemDefinition {
  IsarChargeItemDefinition(
      {required this.id, required this.chargeItemDefinition});
  IsarChargeItemDefinition.fromFhir(ChargeItemDefinition chargeItemDefinition) {
    final Resource newResource = withDbId(chargeItemDefinition);
    id = chargeItemDefinition.dbId!;
    this.chargeItemDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> chargeItemDefinition;
}

@collection
class IsarCitation {
  IsarCitation({required this.id, required this.citation});
  IsarCitation.fromFhir(Citation citation) {
    final Resource newResource = withDbId(citation);
    id = citation.dbId!;
    this.citation = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> citation;
}

@collection
class IsarClaim {
  IsarClaim({required this.id, required this.claim});
  IsarClaim.fromFhir(Claim claim) {
    final Resource newResource = withDbId(claim);
    id = claim.dbId!;
    this.claim = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> claim;
}

@collection
class IsarClaimResponse {
  IsarClaimResponse({required this.id, required this.claimResponse});
  IsarClaimResponse.fromFhir(ClaimResponse claimResponse) {
    final Resource newResource = withDbId(claimResponse);
    id = claimResponse.dbId!;
    this.claimResponse = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> claimResponse;
}

@collection
class IsarClinicalImpression {
  IsarClinicalImpression({required this.id, required this.clinicalImpression});
  IsarClinicalImpression.fromFhir(ClinicalImpression clinicalImpression) {
    final Resource newResource = withDbId(clinicalImpression);
    id = clinicalImpression.dbId!;
    this.clinicalImpression = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> clinicalImpression;
}

@collection
class IsarClinicalUseDefinition {
  IsarClinicalUseDefinition(
      {required this.id, required this.clinicalUseDefinition});
  IsarClinicalUseDefinition.fromFhir(
      ClinicalUseDefinition clinicalUseDefinition) {
    final Resource newResource = withDbId(clinicalUseDefinition);
    id = clinicalUseDefinition.dbId!;
    this.clinicalUseDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> clinicalUseDefinition;
}

@collection
class IsarCodeSystem {
  IsarCodeSystem({required this.id, required this.codeSystem});
  IsarCodeSystem.fromFhir(CodeSystem codeSystem) {
    final Resource newResource = withDbId(codeSystem);
    id = codeSystem.dbId!;
    this.codeSystem = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> codeSystem;
}

@collection
class IsarCommunication {
  IsarCommunication({required this.id, required this.communication});
  IsarCommunication.fromFhir(Communication communication) {
    final Resource newResource = withDbId(communication);
    id = communication.dbId!;
    this.communication = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> communication;
}

@collection
class IsarCommunicationRequest {
  IsarCommunicationRequest(
      {required this.id, required this.communicationRequest});
  IsarCommunicationRequest.fromFhir(CommunicationRequest communicationRequest) {
    final Resource newResource = withDbId(communicationRequest);
    id = communicationRequest.dbId!;
    this.communicationRequest = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> communicationRequest;
}

@collection
class IsarCompartmentDefinition {
  IsarCompartmentDefinition(
      {required this.id, required this.compartmentDefinition});
  IsarCompartmentDefinition.fromFhir(
      CompartmentDefinition compartmentDefinition) {
    final Resource newResource = withDbId(compartmentDefinition);
    id = compartmentDefinition.dbId!;
    this.compartmentDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> compartmentDefinition;
}

@collection
class IsarComposition {
  IsarComposition({required this.id, required this.composition});
  IsarComposition.fromFhir(Composition composition) {
    final Resource newResource = withDbId(composition);
    id = composition.dbId!;
    this.composition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> composition;
}

@collection
class IsarConceptMap {
  IsarConceptMap({required this.id, required this.conceptMap});
  IsarConceptMap.fromFhir(ConceptMap conceptMap) {
    final Resource newResource = withDbId(conceptMap);
    id = conceptMap.dbId!;
    this.conceptMap = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> conceptMap;
}

@collection
class IsarCondition {
  IsarCondition({required this.id, required this.condition});
  IsarCondition.fromFhir(Condition condition) {
    final Resource newResource = withDbId(condition);
    id = condition.dbId!;
    this.condition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> condition;
}

@collection
class IsarConsent {
  IsarConsent({required this.id, required this.consent});
  IsarConsent.fromFhir(Consent consent) {
    final Resource newResource = withDbId(consent);
    id = consent.dbId!;
    this.consent = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> consent;
}

@collection
class IsarContract {
  IsarContract({required this.id, required this.contract});
  IsarContract.fromFhir(Contract contract) {
    final Resource newResource = withDbId(contract);
    id = contract.dbId!;
    this.contract = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> contract;
}

@collection
class IsarCoverage {
  IsarCoverage({required this.id, required this.coverage});
  IsarCoverage.fromFhir(Coverage coverage) {
    final Resource newResource = withDbId(coverage);
    id = coverage.dbId!;
    this.coverage = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> coverage;
}

@collection
class IsarCoverageEligibilityRequest {
  IsarCoverageEligibilityRequest(
      {required this.id, required this.coverageEligibilityRequest});
  IsarCoverageEligibilityRequest.fromFhir(
      CoverageEligibilityRequest coverageEligibilityRequest) {
    final Resource newResource = withDbId(coverageEligibilityRequest);
    id = coverageEligibilityRequest.dbId!;
    this.coverageEligibilityRequest = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> coverageEligibilityRequest;
}

@collection
class IsarCoverageEligibilityResponse {
  IsarCoverageEligibilityResponse(
      {required this.id, required this.coverageEligibilityResponse});
  IsarCoverageEligibilityResponse.fromFhir(
      CoverageEligibilityResponse coverageEligibilityResponse) {
    final Resource newResource = withDbId(coverageEligibilityResponse);
    id = coverageEligibilityResponse.dbId!;
    this.coverageEligibilityResponse = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> coverageEligibilityResponse;
}

@collection
class IsarDetectedIssue {
  IsarDetectedIssue({required this.id, required this.detectedIssue});
  IsarDetectedIssue.fromFhir(DetectedIssue detectedIssue) {
    final Resource newResource = withDbId(detectedIssue);
    id = detectedIssue.dbId!;
    this.detectedIssue = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> detectedIssue;
}

@collection
class IsarDevice {
  IsarDevice({required this.id, required this.device});
  IsarDevice.fromFhir(Device device) {
    final Resource newResource = withDbId(device);
    id = device.dbId!;
    this.device = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> device;
}

@collection
class IsarDeviceDefinition {
  IsarDeviceDefinition({required this.id, required this.deviceDefinition});
  IsarDeviceDefinition.fromFhir(DeviceDefinition deviceDefinition) {
    final Resource newResource = withDbId(deviceDefinition);
    id = deviceDefinition.dbId!;
    this.deviceDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> deviceDefinition;
}

@collection
class IsarDeviceMetric {
  IsarDeviceMetric({required this.id, required this.deviceMetric});
  IsarDeviceMetric.fromFhir(DeviceMetric deviceMetric) {
    final Resource newResource = withDbId(deviceMetric);
    id = deviceMetric.dbId!;
    this.deviceMetric = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> deviceMetric;
}

@collection
class IsarDeviceRequest {
  IsarDeviceRequest({required this.id, required this.deviceRequest});
  IsarDeviceRequest.fromFhir(DeviceRequest deviceRequest) {
    final Resource newResource = withDbId(deviceRequest);
    id = deviceRequest.dbId!;
    this.deviceRequest = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> deviceRequest;
}

@collection
class IsarDeviceUseStatement {
  IsarDeviceUseStatement({required this.id, required this.deviceUseStatement});
  IsarDeviceUseStatement.fromFhir(DeviceUseStatement deviceUseStatement) {
    final Resource newResource = withDbId(deviceUseStatement);
    id = deviceUseStatement.dbId!;
    this.deviceUseStatement = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> deviceUseStatement;
}

@collection
class IsarDiagnosticReport {
  IsarDiagnosticReport({required this.id, required this.diagnosticReport});
  IsarDiagnosticReport.fromFhir(DiagnosticReport diagnosticReport) {
    final Resource newResource = withDbId(diagnosticReport);
    id = diagnosticReport.dbId!;
    this.diagnosticReport = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> diagnosticReport;
}

@collection
class IsarDocumentManifest {
  IsarDocumentManifest({required this.id, required this.documentManifest});
  IsarDocumentManifest.fromFhir(DocumentManifest documentManifest) {
    final Resource newResource = withDbId(documentManifest);
    id = documentManifest.dbId!;
    this.documentManifest = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> documentManifest;
}

@collection
class IsarDocumentReference {
  IsarDocumentReference({required this.id, required this.documentReference});
  IsarDocumentReference.fromFhir(DocumentReference documentReference) {
    final Resource newResource = withDbId(documentReference);
    id = documentReference.dbId!;
    this.documentReference = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> documentReference;
}

@collection
class IsarEncounter {
  IsarEncounter({required this.id, required this.encounter});
  IsarEncounter.fromFhir(Encounter encounter) {
    final Resource newResource = withDbId(encounter);
    id = encounter.dbId!;
    this.encounter = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> encounter;
}

@collection
class IsarEndpoint {
  IsarEndpoint({required this.id, required this.endpoint});
  IsarEndpoint.fromFhir(FhirEndpoint endpoint) {
    final Resource newResource = withDbId(endpoint);
    id = endpoint.dbId!;
    this.endpoint = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> endpoint;
}

@collection
class IsarEnrollmentRequest {
  IsarEnrollmentRequest({required this.id, required this.enrollmentRequest});
  IsarEnrollmentRequest.fromFhir(EnrollmentRequest enrollmentRequest) {
    final Resource newResource = withDbId(enrollmentRequest);
    id = enrollmentRequest.dbId!;
    this.enrollmentRequest = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> enrollmentRequest;
}

@collection
class IsarEnrollmentResponse {
  IsarEnrollmentResponse({required this.id, required this.enrollmentResponse});
  IsarEnrollmentResponse.fromFhir(EnrollmentResponse enrollmentResponse) {
    final Resource newResource = withDbId(enrollmentResponse);
    id = enrollmentResponse.dbId!;
    this.enrollmentResponse = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> enrollmentResponse;
}

@collection
class IsarEpisodeOfCare {
  IsarEpisodeOfCare({required this.id, required this.episodeOfCare});
  IsarEpisodeOfCare.fromFhir(EpisodeOfCare episodeOfCare) {
    final Resource newResource = withDbId(episodeOfCare);
    id = episodeOfCare.dbId!;
    this.episodeOfCare = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> episodeOfCare;
}

@collection
class IsarEventDefinition {
  IsarEventDefinition({required this.id, required this.eventDefinition});
  IsarEventDefinition.fromFhir(EventDefinition eventDefinition) {
    final Resource newResource = withDbId(eventDefinition);
    id = eventDefinition.dbId!;
    this.eventDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> eventDefinition;
}

@collection
class IsarEvidence {
  IsarEvidence({required this.id, required this.evidence});
  IsarEvidence.fromFhir(Evidence evidence) {
    final Resource newResource = withDbId(evidence);
    id = evidence.dbId!;
    this.evidence = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> evidence;
}

@collection
class IsarEvidenceReport {
  IsarEvidenceReport({required this.id, required this.evidenceReport});
  IsarEvidenceReport.fromFhir(EvidenceReport evidenceReport) {
    final Resource newResource = withDbId(evidenceReport);
    id = evidenceReport.dbId!;
    this.evidenceReport = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> evidenceReport;
}

@collection
class IsarEvidenceVariable {
  IsarEvidenceVariable({required this.id, required this.evidenceVariable});
  IsarEvidenceVariable.fromFhir(EvidenceVariable evidenceVariable) {
    final Resource newResource = withDbId(evidenceVariable);
    id = evidenceVariable.dbId!;
    this.evidenceVariable = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> evidenceVariable;
}

@collection
class IsarExampleScenario {
  IsarExampleScenario({required this.id, required this.exampleScenario});
  IsarExampleScenario.fromFhir(ExampleScenario exampleScenario) {
    final Resource newResource = withDbId(exampleScenario);
    id = exampleScenario.dbId!;
    this.exampleScenario = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> exampleScenario;
}

@collection
class IsarExplanationOfBenefit {
  IsarExplanationOfBenefit(
      {required this.id, required this.explanationOfBenefit});
  IsarExplanationOfBenefit.fromFhir(ExplanationOfBenefit explanationOfBenefit) {
    final Resource newResource = withDbId(explanationOfBenefit);
    id = explanationOfBenefit.dbId!;
    this.explanationOfBenefit = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> explanationOfBenefit;
}

@collection
class IsarFamilyMemberHistory {
  IsarFamilyMemberHistory(
      {required this.id, required this.familyMemberHistory});
  IsarFamilyMemberHistory.fromFhir(FamilyMemberHistory familyMemberHistory) {
    final Resource newResource = withDbId(familyMemberHistory);
    id = familyMemberHistory.dbId!;
    this.familyMemberHistory = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> familyMemberHistory;
}

@collection
class IsarFlag {
  IsarFlag({required this.id, required this.flag});
  IsarFlag.fromFhir(Flag flag) {
    final Resource newResource = withDbId(flag);
    id = flag.dbId!;
    this.flag = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> flag;
}

@collection
class IsarGoal {
  IsarGoal({required this.id, required this.goal});
  IsarGoal.fromFhir(Goal goal) {
    final Resource newResource = withDbId(goal);
    id = goal.dbId!;
    this.goal = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> goal;
}

@collection
class IsarGraphDefinition {
  IsarGraphDefinition({required this.id, required this.graphDefinition});
  IsarGraphDefinition.fromFhir(GraphDefinition graphDefinition) {
    final Resource newResource = withDbId(graphDefinition);
    id = graphDefinition.dbId!;
    this.graphDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> graphDefinition;
}

@collection
class IsarGroup {
  IsarGroup({required this.id, required this.group});
  IsarGroup.fromFhir(FhirGroup group) {
    final Resource newResource = withDbId(group);
    id = group.dbId!;
    this.group = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> group;
}

@collection
class IsarGuidanceResponse {
  IsarGuidanceResponse({required this.id, required this.guidanceResponse});
  IsarGuidanceResponse.fromFhir(GuidanceResponse guidanceResponse) {
    final Resource newResource = withDbId(guidanceResponse);
    id = guidanceResponse.dbId!;
    this.guidanceResponse = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> guidanceResponse;
}

@collection
class IsarHealthcareService {
  IsarHealthcareService({required this.id, required this.healthcareService});
  IsarHealthcareService.fromFhir(HealthcareService healthcareService) {
    final Resource newResource = withDbId(healthcareService);
    id = healthcareService.dbId!;
    this.healthcareService = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> healthcareService;
}

@collection
class IsarImagingStudy {
  IsarImagingStudy({required this.id, required this.imagingStudy});
  IsarImagingStudy.fromFhir(ImagingStudy imagingStudy) {
    final Resource newResource = withDbId(imagingStudy);
    id = imagingStudy.dbId!;
    this.imagingStudy = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> imagingStudy;
}

@collection
class IsarImmunization {
  IsarImmunization({required this.id, required this.immunization});
  IsarImmunization.fromFhir(Immunization immunization) {
    final Resource newResource = withDbId(immunization);
    id = immunization.dbId!;
    this.immunization = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> immunization;
}

@collection
class IsarImmunizationEvaluation {
  IsarImmunizationEvaluation(
      {required this.id, required this.immunizationEvaluation});
  IsarImmunizationEvaluation.fromFhir(
      ImmunizationEvaluation immunizationEvaluation) {
    final Resource newResource = withDbId(immunizationEvaluation);
    id = immunizationEvaluation.dbId!;
    this.immunizationEvaluation = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> immunizationEvaluation;
}

@collection
class IsarImmunizationRecommendation {
  IsarImmunizationRecommendation(
      {required this.id, required this.immunizationRecommendation});
  IsarImmunizationRecommendation.fromFhir(
      ImmunizationRecommendation immunizationRecommendation) {
    final Resource newResource = withDbId(immunizationRecommendation);
    id = immunizationRecommendation.dbId!;
    this.immunizationRecommendation = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> immunizationRecommendation;
}

@collection
class IsarImplementationGuide {
  IsarImplementationGuide(
      {required this.id, required this.implementationGuide});
  IsarImplementationGuide.fromFhir(ImplementationGuide implementationGuide) {
    final Resource newResource = withDbId(implementationGuide);
    id = implementationGuide.dbId!;
    this.implementationGuide = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> implementationGuide;
}

@collection
class IsarIngredient {
  IsarIngredient({required this.id, required this.ingredient});
  IsarIngredient.fromFhir(Ingredient ingredient) {
    final Resource newResource = withDbId(ingredient);
    id = ingredient.dbId!;
    this.ingredient = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> ingredient;
}

@collection
class IsarInsurancePlan {
  IsarInsurancePlan({required this.id, required this.insurancePlan});
  IsarInsurancePlan.fromFhir(InsurancePlan insurancePlan) {
    final Resource newResource = withDbId(insurancePlan);
    id = insurancePlan.dbId!;
    this.insurancePlan = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> insurancePlan;
}

@collection
class IsarInvoice {
  IsarInvoice({required this.id, required this.invoice});
  IsarInvoice.fromFhir(Invoice invoice) {
    final Resource newResource = withDbId(invoice);
    id = invoice.dbId!;
    this.invoice = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> invoice;
}

@collection
class IsarLibrary {
  IsarLibrary({required this.id, required this.library});
  IsarLibrary.fromFhir(Library library) {
    final Resource newResource = withDbId(library);
    id = library.dbId!;
    this.library = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> library;
}

@collection
class IsarLinkage {
  IsarLinkage({required this.id, required this.linkage});
  IsarLinkage.fromFhir(Linkage linkage) {
    final Resource newResource = withDbId(linkage);
    id = linkage.dbId!;
    this.linkage = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> linkage;
}

@collection
class IsarList {
  IsarList({required this.id, required this.list});
  IsarList.fromFhir(FhirList list) {
    final Resource newResource = withDbId(list);
    id = list.dbId!;
    this.list = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> list;
}

@collection
class IsarLocation {
  IsarLocation({required this.id, required this.location});
  IsarLocation.fromFhir(Location location) {
    final Resource newResource = withDbId(location);
    id = location.dbId!;
    this.location = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> location;
}

@collection
class IsarManufacturedItemDefinition {
  IsarManufacturedItemDefinition(
      {required this.id, required this.manufacturedItemDefinition});
  IsarManufacturedItemDefinition.fromFhir(
      ManufacturedItemDefinition manufacturedItemDefinition) {
    final Resource newResource = withDbId(manufacturedItemDefinition);
    id = manufacturedItemDefinition.dbId!;
    this.manufacturedItemDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> manufacturedItemDefinition;
}

@collection
class IsarMeasure {
  IsarMeasure({required this.id, required this.measure});
  IsarMeasure.fromFhir(Measure measure) {
    final Resource newResource = withDbId(measure);
    id = measure.dbId!;
    this.measure = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> measure;
}

@collection
class IsarMeasureReport {
  IsarMeasureReport({required this.id, required this.measureReport});
  IsarMeasureReport.fromFhir(MeasureReport measureReport) {
    final Resource newResource = withDbId(measureReport);
    id = measureReport.dbId!;
    this.measureReport = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> measureReport;
}

@collection
class IsarMedia {
  IsarMedia({required this.id, required this.media});
  IsarMedia.fromFhir(Media media) {
    final Resource newResource = withDbId(media);
    id = media.dbId!;
    this.media = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> media;
}

@collection
class IsarMedication {
  IsarMedication({required this.id, required this.medication});
  IsarMedication.fromFhir(Medication medication) {
    final Resource newResource = withDbId(medication);
    id = medication.dbId!;
    this.medication = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> medication;
}

@collection
class IsarMedicationAdministration {
  IsarMedicationAdministration(
      {required this.id, required this.medicationAdministration});
  IsarMedicationAdministration.fromFhir(
      MedicationAdministration medicationAdministration) {
    final Resource newResource = withDbId(medicationAdministration);
    id = medicationAdministration.dbId!;
    this.medicationAdministration = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> medicationAdministration;
}

@collection
class IsarMedicationDispense {
  IsarMedicationDispense({required this.id, required this.medicationDispense});
  IsarMedicationDispense.fromFhir(MedicationDispense medicationDispense) {
    final Resource newResource = withDbId(medicationDispense);
    id = medicationDispense.dbId!;
    this.medicationDispense = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> medicationDispense;
}

@collection
class IsarMedicationKnowledge {
  IsarMedicationKnowledge(
      {required this.id, required this.medicationKnowledge});
  IsarMedicationKnowledge.fromFhir(MedicationKnowledge medicationKnowledge) {
    final Resource newResource = withDbId(medicationKnowledge);
    id = medicationKnowledge.dbId!;
    this.medicationKnowledge = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> medicationKnowledge;
}

@collection
class IsarMedicationRequest {
  IsarMedicationRequest({required this.id, required this.medicationRequest});
  IsarMedicationRequest.fromFhir(MedicationRequest medicationRequest) {
    final Resource newResource = withDbId(medicationRequest);
    id = medicationRequest.dbId!;
    this.medicationRequest = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> medicationRequest;
}

@collection
class IsarMedicationStatement {
  IsarMedicationStatement(
      {required this.id, required this.medicationStatement});
  IsarMedicationStatement.fromFhir(MedicationStatement medicationStatement) {
    final Resource newResource = withDbId(medicationStatement);
    id = medicationStatement.dbId!;
    this.medicationStatement = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> medicationStatement;
}

@collection
class IsarMedicinalProductDefinition {
  IsarMedicinalProductDefinition(
      {required this.id, required this.medicinalProductDefinition});
  IsarMedicinalProductDefinition.fromFhir(
      MedicinalProductDefinition medicinalProductDefinition) {
    final Resource newResource = withDbId(medicinalProductDefinition);
    id = medicinalProductDefinition.dbId!;
    this.medicinalProductDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> medicinalProductDefinition;
}

@collection
class IsarMessageDefinition {
  IsarMessageDefinition({required this.id, required this.messageDefinition});
  IsarMessageDefinition.fromFhir(MessageDefinition messageDefinition) {
    final Resource newResource = withDbId(messageDefinition);
    id = messageDefinition.dbId!;
    this.messageDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> messageDefinition;
}

@collection
class IsarMessageHeader {
  IsarMessageHeader({required this.id, required this.messageHeader});
  IsarMessageHeader.fromFhir(MessageHeader messageHeader) {
    final Resource newResource = withDbId(messageHeader);
    id = messageHeader.dbId!;
    this.messageHeader = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> messageHeader;
}

@collection
class IsarMolecularSequence {
  IsarMolecularSequence({required this.id, required this.molecularSequence});
  IsarMolecularSequence.fromFhir(MolecularSequence molecularSequence) {
    final Resource newResource = withDbId(molecularSequence);
    id = molecularSequence.dbId!;
    this.molecularSequence = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> molecularSequence;
}

@collection
class IsarNamingSystem {
  IsarNamingSystem({required this.id, required this.namingSystem});
  IsarNamingSystem.fromFhir(NamingSystem namingSystem) {
    final Resource newResource = withDbId(namingSystem);
    id = namingSystem.dbId!;
    this.namingSystem = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> namingSystem;
}

@collection
class IsarNutritionOrder {
  IsarNutritionOrder({required this.id, required this.nutritionOrder});
  IsarNutritionOrder.fromFhir(NutritionOrder nutritionOrder) {
    final Resource newResource = withDbId(nutritionOrder);
    id = nutritionOrder.dbId!;
    this.nutritionOrder = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> nutritionOrder;
}

@collection
class IsarNutritionProduct {
  IsarNutritionProduct({required this.id, required this.nutritionProduct});
  IsarNutritionProduct.fromFhir(NutritionProduct nutritionProduct) {
    final Resource newResource = withDbId(nutritionProduct);
    id = nutritionProduct.dbId!;
    this.nutritionProduct = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> nutritionProduct;
}

@collection
class IsarObservation {
  IsarObservation({required this.id, required this.observation});
  IsarObservation.fromFhir(Observation observation) {
    final Resource newResource = withDbId(observation);
    id = observation.dbId!;
    this.observation = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> observation;
}

@collection
class IsarObservationDefinition {
  IsarObservationDefinition(
      {required this.id, required this.observationDefinition});
  IsarObservationDefinition.fromFhir(
      ObservationDefinition observationDefinition) {
    final Resource newResource = withDbId(observationDefinition);
    id = observationDefinition.dbId!;
    this.observationDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> observationDefinition;
}

@collection
class IsarOperationDefinition {
  IsarOperationDefinition(
      {required this.id, required this.operationDefinition});
  IsarOperationDefinition.fromFhir(OperationDefinition operationDefinition) {
    final Resource newResource = withDbId(operationDefinition);
    id = operationDefinition.dbId!;
    this.operationDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> operationDefinition;
}

@collection
class IsarOperationOutcome {
  IsarOperationOutcome({required this.id, required this.operationOutcome});
  IsarOperationOutcome.fromFhir(OperationOutcome operationOutcome) {
    final Resource newResource = withDbId(operationOutcome);
    id = operationOutcome.dbId!;
    this.operationOutcome = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> operationOutcome;
}

@collection
class IsarOrganization {
  IsarOrganization({required this.id, required this.organization});
  IsarOrganization.fromFhir(Organization organization) {
    final Resource newResource = withDbId(organization);
    id = organization.dbId!;
    this.organization = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> organization;
}

@collection
class IsarOrganizationAffiliation {
  IsarOrganizationAffiliation(
      {required this.id, required this.organizationAffiliation});
  IsarOrganizationAffiliation.fromFhir(
      OrganizationAffiliation organizationAffiliation) {
    final Resource newResource = withDbId(organizationAffiliation);
    id = organizationAffiliation.dbId!;
    this.organizationAffiliation = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> organizationAffiliation;
}

@collection
class IsarPackagedProductDefinition {
  IsarPackagedProductDefinition(
      {required this.id, required this.packagedProductDefinition});
  IsarPackagedProductDefinition.fromFhir(
      PackagedProductDefinition packagedProductDefinition) {
    final Resource newResource = withDbId(packagedProductDefinition);
    id = packagedProductDefinition.dbId!;
    this.packagedProductDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> packagedProductDefinition;
}

@collection
class IsarParameters {
  IsarParameters({required this.id, required this.parameters});
  IsarParameters.fromFhir(Parameters parameters) {
    final Resource newResource = withDbId(parameters);
    id = parameters.dbId!;
    this.parameters = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> parameters;
}

@collection
class IsarPatient {
  IsarPatient({required this.id, required this.patient});
  IsarPatient.fromFhir(Patient patient) {
    final Resource newResource = withDbId(patient);
    id = patient.dbId!;
    this.patient = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> patient;
}

@collection
class IsarPaymentNotice {
  IsarPaymentNotice({required this.id, required this.paymentNotice});
  IsarPaymentNotice.fromFhir(PaymentNotice paymentNotice) {
    final Resource newResource = withDbId(paymentNotice);
    id = paymentNotice.dbId!;
    this.paymentNotice = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> paymentNotice;
}

@collection
class IsarPaymentReconciliation {
  IsarPaymentReconciliation(
      {required this.id, required this.paymentReconciliation});
  IsarPaymentReconciliation.fromFhir(
      PaymentReconciliation paymentReconciliation) {
    final Resource newResource = withDbId(paymentReconciliation);
    id = paymentReconciliation.dbId!;
    this.paymentReconciliation = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> paymentReconciliation;
}

@collection
class IsarPerson {
  IsarPerson({required this.id, required this.person});
  IsarPerson.fromFhir(Person person) {
    final Resource newResource = withDbId(person);
    id = person.dbId!;
    this.person = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> person;
}

@collection
class IsarPlanDefinition {
  IsarPlanDefinition({required this.id, required this.planDefinition});
  IsarPlanDefinition.fromFhir(PlanDefinition planDefinition) {
    final Resource newResource = withDbId(planDefinition);
    id = planDefinition.dbId!;
    this.planDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> planDefinition;
}

@collection
class IsarPractitioner {
  IsarPractitioner({required this.id, required this.practitioner});
  IsarPractitioner.fromFhir(Practitioner practitioner) {
    final Resource newResource = withDbId(practitioner);
    id = practitioner.dbId!;
    this.practitioner = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> practitioner;
}

@collection
class IsarPractitionerRole {
  IsarPractitionerRole({required this.id, required this.practitionerRole});
  IsarPractitionerRole.fromFhir(PractitionerRole practitionerRole) {
    final Resource newResource = withDbId(practitionerRole);
    id = practitionerRole.dbId!;
    this.practitionerRole = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> practitionerRole;
}

@collection
class IsarProcedure {
  IsarProcedure({required this.id, required this.procedure});
  IsarProcedure.fromFhir(Procedure procedure) {
    final Resource newResource = withDbId(procedure);
    id = procedure.dbId!;
    this.procedure = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> procedure;
}

@collection
class IsarProvenance {
  IsarProvenance({required this.id, required this.provenance});
  IsarProvenance.fromFhir(Provenance provenance) {
    final Resource newResource = withDbId(provenance);
    id = provenance.dbId!;
    this.provenance = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> provenance;
}

@collection
class IsarQuestionnaire {
  IsarQuestionnaire({required this.id, required this.questionnaire});
  IsarQuestionnaire.fromFhir(Questionnaire questionnaire) {
    final Resource newResource = withDbId(questionnaire);
    id = questionnaire.dbId!;
    this.questionnaire = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> questionnaire;
}

@collection
class IsarQuestionnaireResponse {
  IsarQuestionnaireResponse(
      {required this.id, required this.questionnaireResponse});
  IsarQuestionnaireResponse.fromFhir(
      QuestionnaireResponse questionnaireResponse) {
    final Resource newResource = withDbId(questionnaireResponse);
    id = questionnaireResponse.dbId!;
    this.questionnaireResponse = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> questionnaireResponse;
}

@collection
class IsarRegulatedAuthorization {
  IsarRegulatedAuthorization(
      {required this.id, required this.regulatedAuthorization});
  IsarRegulatedAuthorization.fromFhir(
      RegulatedAuthorization regulatedAuthorization) {
    final Resource newResource = withDbId(regulatedAuthorization);
    id = regulatedAuthorization.dbId!;
    this.regulatedAuthorization = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> regulatedAuthorization;
}

@collection
class IsarRelatedPerson {
  IsarRelatedPerson({required this.id, required this.relatedPerson});
  IsarRelatedPerson.fromFhir(RelatedPerson relatedPerson) {
    final Resource newResource = withDbId(relatedPerson);
    id = relatedPerson.dbId!;
    this.relatedPerson = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> relatedPerson;
}

@collection
class IsarRequestGroup {
  IsarRequestGroup({required this.id, required this.requestGroup});
  IsarRequestGroup.fromFhir(RequestGroup requestGroup) {
    final Resource newResource = withDbId(requestGroup);
    id = requestGroup.dbId!;
    this.requestGroup = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> requestGroup;
}

@collection
class IsarResearchDefinition {
  IsarResearchDefinition({required this.id, required this.researchDefinition});
  IsarResearchDefinition.fromFhir(ResearchDefinition researchDefinition) {
    final Resource newResource = withDbId(researchDefinition);
    id = researchDefinition.dbId!;
    this.researchDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> researchDefinition;
}

@collection
class IsarResearchElementDefinition {
  IsarResearchElementDefinition(
      {required this.id, required this.researchElementDefinition});
  IsarResearchElementDefinition.fromFhir(
      ResearchElementDefinition researchElementDefinition) {
    final Resource newResource = withDbId(researchElementDefinition);
    id = researchElementDefinition.dbId!;
    this.researchElementDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> researchElementDefinition;
}

@collection
class IsarResearchStudy {
  IsarResearchStudy({required this.id, required this.researchStudy});
  IsarResearchStudy.fromFhir(ResearchStudy researchStudy) {
    final Resource newResource = withDbId(researchStudy);
    id = researchStudy.dbId!;
    this.researchStudy = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> researchStudy;
}

@collection
class IsarResearchSubject {
  IsarResearchSubject({required this.id, required this.researchSubject});
  IsarResearchSubject.fromFhir(ResearchSubject researchSubject) {
    final Resource newResource = withDbId(researchSubject);
    id = researchSubject.dbId!;
    this.researchSubject = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> researchSubject;
}

@collection
class IsarRiskAssessment {
  IsarRiskAssessment({required this.id, required this.riskAssessment});
  IsarRiskAssessment.fromFhir(RiskAssessment riskAssessment) {
    final Resource newResource = withDbId(riskAssessment);
    id = riskAssessment.dbId!;
    this.riskAssessment = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> riskAssessment;
}

@collection
class IsarSchedule {
  IsarSchedule({required this.id, required this.schedule});
  IsarSchedule.fromFhir(Schedule schedule) {
    final Resource newResource = withDbId(schedule);
    id = schedule.dbId!;
    this.schedule = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> schedule;
}

@collection
class IsarSearchParameter {
  IsarSearchParameter({required this.id, required this.searchParameter});
  IsarSearchParameter.fromFhir(SearchParameter searchParameter) {
    final Resource newResource = withDbId(searchParameter);
    id = searchParameter.dbId!;
    this.searchParameter = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> searchParameter;
}

@collection
class IsarServiceRequest {
  IsarServiceRequest({required this.id, required this.serviceRequest});
  IsarServiceRequest.fromFhir(ServiceRequest serviceRequest) {
    final Resource newResource = withDbId(serviceRequest);
    id = serviceRequest.dbId!;
    this.serviceRequest = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> serviceRequest;
}

@collection
class IsarSlot {
  IsarSlot({required this.id, required this.slot});
  IsarSlot.fromFhir(Slot slot) {
    final Resource newResource = withDbId(slot);
    id = slot.dbId!;
    this.slot = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> slot;
}

@collection
class IsarSpecimen {
  IsarSpecimen({required this.id, required this.specimen});
  IsarSpecimen.fromFhir(Specimen specimen) {
    final Resource newResource = withDbId(specimen);
    id = specimen.dbId!;
    this.specimen = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> specimen;
}

@collection
class IsarSpecimenDefinition {
  IsarSpecimenDefinition({required this.id, required this.specimenDefinition});
  IsarSpecimenDefinition.fromFhir(SpecimenDefinition specimenDefinition) {
    final Resource newResource = withDbId(specimenDefinition);
    id = specimenDefinition.dbId!;
    this.specimenDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> specimenDefinition;
}

@collection
class IsarStructureDefinition {
  IsarStructureDefinition(
      {required this.id, required this.structureDefinition});
  IsarStructureDefinition.fromFhir(StructureDefinition structureDefinition) {
    final Resource newResource = withDbId(structureDefinition);
    id = structureDefinition.dbId!;
    this.structureDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> structureDefinition;
}

@collection
class IsarStructureMap {
  IsarStructureMap({required this.id, required this.structureMap});
  IsarStructureMap.fromFhir(StructureMap structureMap) {
    final Resource newResource = withDbId(structureMap);
    id = structureMap.dbId!;
    this.structureMap = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> structureMap;
}

@collection
class IsarSubscription {
  IsarSubscription({required this.id, required this.subscription});
  IsarSubscription.fromFhir(Subscription subscription) {
    final Resource newResource = withDbId(subscription);
    id = subscription.dbId!;
    this.subscription = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> subscription;
}

@collection
class IsarSubscriptionStatus {
  IsarSubscriptionStatus({required this.id, required this.subscriptionStatus});
  IsarSubscriptionStatus.fromFhir(SubscriptionStatus subscriptionStatus) {
    final Resource newResource = withDbId(subscriptionStatus);
    id = subscriptionStatus.dbId!;
    this.subscriptionStatus = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> subscriptionStatus;
}

@collection
class IsarSubscriptionTopic {
  IsarSubscriptionTopic({required this.id, required this.subscriptionTopic});
  IsarSubscriptionTopic.fromFhir(SubscriptionTopic subscriptionTopic) {
    final Resource newResource = withDbId(subscriptionTopic);
    id = subscriptionTopic.dbId!;
    this.subscriptionTopic = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> subscriptionTopic;
}

@collection
class IsarSubstance {
  IsarSubstance({required this.id, required this.substance});
  IsarSubstance.fromFhir(Substance substance) {
    final Resource newResource = withDbId(substance);
    id = substance.dbId!;
    this.substance = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> substance;
}

@collection
class IsarSubstanceDefinition {
  IsarSubstanceDefinition(
      {required this.id, required this.substanceDefinition});
  IsarSubstanceDefinition.fromFhir(SubstanceDefinition substanceDefinition) {
    final Resource newResource = withDbId(substanceDefinition);
    id = substanceDefinition.dbId!;
    this.substanceDefinition = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> substanceDefinition;
}

@collection
class IsarSupplyDelivery {
  IsarSupplyDelivery({required this.id, required this.supplyDelivery});
  IsarSupplyDelivery.fromFhir(SupplyDelivery supplyDelivery) {
    final Resource newResource = withDbId(supplyDelivery);
    id = supplyDelivery.dbId!;
    this.supplyDelivery = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> supplyDelivery;
}

@collection
class IsarSupplyRequest {
  IsarSupplyRequest({required this.id, required this.supplyRequest});
  IsarSupplyRequest.fromFhir(SupplyRequest supplyRequest) {
    final Resource newResource = withDbId(supplyRequest);
    id = supplyRequest.dbId!;
    this.supplyRequest = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> supplyRequest;
}

@collection
class IsarTask {
  IsarTask({required this.id, required this.task});
  IsarTask.fromFhir(Task task) {
    final Resource newResource = withDbId(task);
    id = task.dbId!;
    this.task = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> task;
}

@collection
class IsarTerminologyCapabilities {
  IsarTerminologyCapabilities(
      {required this.id, required this.terminologyCapabilities});
  IsarTerminologyCapabilities.fromFhir(
      TerminologyCapabilities terminologyCapabilities) {
    final Resource newResource = withDbId(terminologyCapabilities);
    id = terminologyCapabilities.dbId!;
    this.terminologyCapabilities = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> terminologyCapabilities;
}

@collection
class IsarTestReport {
  IsarTestReport({required this.id, required this.testReport});
  IsarTestReport.fromFhir(TestReport testReport) {
    final Resource newResource = withDbId(testReport);
    id = testReport.dbId!;
    this.testReport = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> testReport;
}

@collection
class IsarTestScript {
  IsarTestScript({required this.id, required this.testScript});
  IsarTestScript.fromFhir(TestScript testScript) {
    final Resource newResource = withDbId(testScript);
    id = testScript.dbId!;
    this.testScript = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> testScript;
}

@collection
class IsarValueSet {
  IsarValueSet({required this.id, required this.valueSet});
  IsarValueSet.fromFhir(ValueSet valueSet) {
    final Resource newResource = withDbId(valueSet);
    id = valueSet.dbId!;
    this.valueSet = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> valueSet;
}

@collection
class IsarVerificationResult {
  IsarVerificationResult({required this.id, required this.verificationResult});
  IsarVerificationResult.fromFhir(VerificationResult verificationResult) {
    final Resource newResource = withDbId(verificationResult);
    id = verificationResult.dbId!;
    this.verificationResult = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> verificationResult;
}

@collection
class IsarVisionPrescription {
  IsarVisionPrescription({required this.id, required this.visionPrescription});
  IsarVisionPrescription.fromFhir(VisionPrescription visionPrescription) {
    final Resource newResource = withDbId(visionPrescription);
    id = visionPrescription.dbId!;
    this.visionPrescription = newResource.toJson();
  }
  @Id()
  late int id;
  late Map<String, dynamic> visionPrescription;
}
