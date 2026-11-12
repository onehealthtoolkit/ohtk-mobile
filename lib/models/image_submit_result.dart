import 'package:podd_app/models/entities/base_report_image.dart';
import 'package:podd_app/models/operation_exception_failure.dart';
import 'package:podd_app/models/submission_problem.dart';

abstract class ImageSubmitResult {}

class ImageSubmitSuccess extends ImageSubmitResult {
  final BaseReportImage _image;

  ImageSubmitSuccess(this._image);

  BaseReportImage get image => _image;
}

class ImageSubmitFailure extends OperationExceptionFailure
    implements ImageSubmitResult {
  final SubmissionProblem? problem;
  ImageSubmitFailure(e, {this.problem}) : super(e);
}
