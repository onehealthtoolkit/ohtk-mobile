import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:stacked/stacked.dart';

class FollowupReportViewModel extends FutureViewModel<FollowupReport> {
  ReportApi reportApi = locator<ReportApi>();
  ConfigService configService = locator<ConfigService>();

  String id;

  FollowupReportViewModel(this.id);

  @override
  Future<FollowupReport> futureToRun() async {
    final followup = await reportApi.getFollowupReport(id);
    return followup.data;
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
}
