import 'package:podd_app/models/operation_exception_failure.dart';

abstract class ProfileResult {}

class ProfileSuccess extends ProfileResult {
  bool success;
  String? message;
  ProfileSuccess({required this.success, this.message});
}

class ProfileUploadSuccess extends ProfileResult {
  bool success;
  String? message;
  String? avatarUrl;

  ProfileUploadSuccess({required this.success, this.message, this.avatarUrl});
}

class ProfileFailure extends OperationExceptionFailure with ProfileResult {
  ProfileFailure(e) : super(e);
}

class ProfileInvalidData extends ProfileResult {}
