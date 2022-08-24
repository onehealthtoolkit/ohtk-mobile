import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

class CommentQueryResult {
  List<Comment> data;

  CommentQueryResult(this.data);
}

class CommentSubmitResult {}

class CommentSubmitSuccess extends CommentSubmitResult {
  Comment comment;
  CommentSubmitSuccess({required this.comment});
}

class CommentSubmitProblem extends CommentSubmitResult {
  String message;
  CommentSubmitProblem({required this.message});
}

class CommentSubmitFailure extends OperationExceptionFailure
    with CommentSubmitResult {
  CommentSubmitFailure(e) : super(e);
}
