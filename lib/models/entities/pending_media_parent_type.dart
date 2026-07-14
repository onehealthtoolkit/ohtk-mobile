class PendingMediaParentType {
  static const incidentReport = 'incident_report';
  static const observationSubject = 'observation_subject';
  static const observationMonitoring = 'observation_monitoring';

  static bool isObservation(String parentType) {
    return parentType == observationSubject ||
        parentType == observationMonitoring;
  }

  static String? recordTypeFor(String parentType) {
    switch (parentType) {
      case observationSubject:
        return 'subject';
      case observationMonitoring:
        return 'monitoring';
      default:
        return null;
    }
  }
}
