import 'package:podd_app/locator.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:stacked/stacked.dart';

class ConsentViewModel extends FutureViewModel<String> {
  ReportApi reportApi = locator<ReportApi>();
  ConfigService configService = locator<ConfigService>();

  ConsentViewModel();

  bool isConsent = false;

  @override
  Future<String> futureToRun() async {
    // TODO Get consent description
    await Future.delayed(Duration(seconds: 1));
    return "consent datail";
  }

  setConsent(bool? value) {
    isConsent = value ?? false;
    notifyListeners();
  }
}
