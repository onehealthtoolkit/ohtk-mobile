import 'package:podd_app/models/operation_exception_failure.dart';

abstract class ImageSubmitResult {}

class ImageSubmitSuccess extends ImageSubmitResult {
  final String id;
  ImageSubmitSuccess({required this.id});
}

class ImageSubmitFailure extends OperationExceptionFailure
    with ImageSubmitResult {
  ImageSubmitFailure(e) : super(e);
}
