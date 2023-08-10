import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:stacked/stacked.dart';

class IncidentReportViewModel extends FutureViewModel<IncidentReport> {
  ReportApi reportApi = locator<ReportApi>();
  ConfigService configService = locator<ConfigService>();

  String id;
  bool _mapRenderedComplete = false;

  IncidentReportViewModel(this.id);

  @override
  Future<IncidentReport> futureToRun() async {
    final incident = await reportApi.getIncidentReport(id);
    return incident.data;
  }

  resolveImagePath(String path) {
    return path;
  }

  List<double>? get latlng {
    List<double>? latlng;
    var location = data?.gpsLocation;
    if (location != null) {
      if (location.isNotEmpty) {
        var lnglat = data!.gpsLocation!.split(",");
        latlng = [double.parse(lnglat[1]), double.parse(lnglat[0])];
      }
    }
    return latlng;
  }

  bool get mapRenderedComplete => latlng != null ? _mapRenderedComplete : true;

  set mapRenderedComplete(bool value) {
    _mapRenderedComplete = value;
    notifyListeners();
  }
}
