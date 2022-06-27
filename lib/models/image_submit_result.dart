import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class ImageSubmitResult {}

class ImageSubmitSuccess extends ImageSubmitResult {
  final IncidentReportImage _image;

  ImageSubmitSuccess(this._image);

  IncidentReportImage get image => _image;
}

class ImageSubmitFailure extends OperationExceptionFailure
    with ImageSubmitResult {
  ImageSubmitFailure(e) : super(e);
}
