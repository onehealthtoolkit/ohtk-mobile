import 'package:podd_app/models/entities/base_report_file.dart';
import 'package:podd_app/models/operation_exception_failure.dart';
import 'package:podd_app/models/submission_problem.dart';

abstract class FileSubmitResult {}

class FileSubmitSuccess extends FileSubmitResult {
  final BaseReportFile _file;

  FileSubmitSuccess(this._file);

  BaseReportFile get file => _file;
}

class FileSubmitFailure extends OperationExceptionFailure
    implements FileSubmitResult {
  final SubmissionProblem? problem;
  FileSubmitFailure(e, {this.problem}) : super(e);
}
