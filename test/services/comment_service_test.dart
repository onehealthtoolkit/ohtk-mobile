import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/comment_result.dart';
import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/models/entities/user.dart';
import 'package:podd_app/services/api/comment_api.dart';
import 'package:podd_app/services/comment_service.dart';

class FakeCommentApi extends Fake implements CommentApi {
  List<Comment> fetchedComments = [];
  CommentSubmitResult submitResult = CommentSubmitProblem(message: 'Not sent');

  @override
  Future<CommentQueryResult> fetchComments(int threadId) async {
    return CommentQueryResult(fetchedComments);
  }

  @override
  Future<CommentSubmitResult> submit(
    String body,
    int threadId,
    List<Uint8List> attachments,
  ) async {
    return submitResult;
  }
}

Comment comment(String id, String createdAt) => Comment(
      id: id,
      body: 'Comment $id',
      user: User(id: '1', username: 'reporter', firstName: '', lastName: ''),
      createdAt: DateTime.parse(createdAt),
      attachments: [],
      threadId: 7,
    );

void main() {
  late FakeCommentApi api;
  late CommentService service;

  setUp(() async {
    await locator.reset();
    api = FakeCommentApi();
    locator.registerSingleton<CommentApi>(api);
    service = CommentService();
  });

  tearDown(() => locator.reset());

  test('loads newest-first API results as an oldest-first conversation',
      () async {
    api.fetchedComments = [
      comment('3', '2026-11-05T03:00:00Z'),
      comment('1', '2026-11-05T02:00:00Z'),
      comment('2', '2026-11-05T01:00:00Z'),
    ];

    await service.fetchComments(7);

    expect(service.comments.map((item) => item.id), ['2', '1', '3']);
    expect(service.comments.last.id, '3');
  });

  test('uses numeric ascending IDs when creation times are equal', () async {
    api.fetchedComments = [
      comment('10', '2026-11-05T03:00:00Z'),
      comment('2', '2026-11-05T03:00:00Z'),
      comment('1', '2026-11-05T03:00:00Z'),
    ];

    await service.fetchComments(7);

    expect(service.comments.map((item) => item.id), ['1', '2', '10']);
  });

  test('refresh preserves order regardless of API order without duplicates',
      () async {
    final older = comment('1', '2026-11-05T01:00:00Z');
    final newer = comment('2', '2026-11-05T02:00:00Z');
    api.fetchedComments = [older, newer];
    await service.fetchComments(7);

    api.fetchedComments = [newer, older];
    await service.fetchComments(7);

    expect(service.comments.map((item) => item.id), ['1', '2']);
  });

  test('successful submission uses the same order before and after refresh',
      () async {
    final first = comment('1', '2026-11-05T01:00:00Z');
    final last = comment('10', '2026-11-05T02:00:00Z');
    final submitted = comment('2', '2026-11-05T02:00:00Z');
    api.fetchedComments = [first, last];
    await service.fetchComments(7);
    api.submitResult = CommentSubmitSuccess(comment: submitted);

    await service.submitComment(submitted.body, 7, []);

    expect(service.comments.map((item) => item.id), ['1', '2', '10']);

    api.fetchedComments = [last, submitted, first];
    await service.fetchComments(7);

    expect(service.comments.map((item) => item.id), ['1', '2', '10']);
  });

  test('latest submitted comment remains at the end of the conversation',
      () async {
    api.fetchedComments = [comment('1', '2026-11-05T01:00:00Z')];
    await service.fetchComments(7);
    api.submitResult = CommentSubmitSuccess(
      comment: comment('2', '2026-11-05T02:00:00Z'),
    );

    await service.submitComment('New comment', 7, []);

    expect(service.comments.map((item) => item.id), ['1', '2']);
    expect(service.comments.last.id, '2');
  });

  test('failed submission keeps the loaded conversation unchanged', () async {
    api.fetchedComments = [comment('1', '2026-11-05T01:00:00Z')];
    await service.fetchComments(7);

    await service.submitComment('Not sent', 7, []);

    expect(service.comments.map((item) => item.id), ['1']);
  });
}
