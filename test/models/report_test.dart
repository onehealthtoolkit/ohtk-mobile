import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/models/entities/report.dart';

void main() {
  test('Report preserves village id for offline retry', () {
    final report = Report(
      id: 'report-1',
      data: const {'symptom': 'cough'},
      reportTypeId: 'type-1',
      reportTypeName: 'Animal Sick/Death',
      incidentDate: DateTime(2026, 8, 11),
      gpsLocation: null,
      villageId: 11,
      incidentInAuthority: true,
      testFlag: false,
    );

    final restored = Report.fromMap(report.toMap());

    expect(restored.villageId, 11);
    expect(restored.gpsLocation, isNull);
  });
}
