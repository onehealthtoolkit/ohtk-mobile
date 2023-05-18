import 'package:podd_app/models/entities/base_report_file.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class FileSubmitResult {}

class FileSubmitSuccess extends FileSubmitResult {
  final BaseReportFile _file;

  FileSubmitSuccess(this._file);

  BaseReportFile get file => _file;
}

class FileSubmitFailure extends OperationExceptionFailure
    with FileSubmitResult {
  FileSubmitFailure(e) : super(e);
}
