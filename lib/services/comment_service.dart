import 'dart:typed_data';

import 'package:podd_app/locator.dart';
import 'package:podd_app/models/comment_result.dart';
import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/services/api/comment_api.dart';
import 'package:stacked/stacked.dart';

abstract class ICommentService with ListenableServiceMixin {
  List<Comment> get comments;

  Future<void> fetchComments(int threadId);

  submitComment(String body, int threadId, List<Uint8List> images);
}

class CommentService extends ICommentService {
  final _commentApi = locator<CommentApi>();

  final ReactiveList<Comment> _comments = ReactiveList();

  CommentService() {
    listenToReactiveValues([_comments]);
  }

  @override
  Future<void> fetchComments(int threadId) async {
    _comments.clear();
    var result = await _commentApi.fetchComments(threadId);
    _comments.addAll(result.data);
    _sortComments();
  }

  @override
  List<Comment> get comments => _comments;

  @override
  submitComment(String body, int threadId, List<Uint8List> images) async {
    var result = await _commentApi.submit(body, threadId, images);
    if (result is CommentSubmitSuccess) {
      _comments.add(result.comment);
      _sortComments();
    }
  }

  void _sortComments() {
    // Keep the mobile conversation oldest first regardless of API ordering.
    _comments.sort((a, b) {
      final byCreatedAt = a.createdAt.compareTo(b.createdAt);
      if (byCreatedAt != 0) return byCreatedAt;
      return int.parse(a.id).compareTo(int.parse(b.id));
    });
  }
}
