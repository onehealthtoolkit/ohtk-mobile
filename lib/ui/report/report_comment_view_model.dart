import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/services/comment_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stacked/stacked.dart';

class ReportCommentViewModel extends ReactiveViewModel {
  ICommentService commentService = locator<ICommentService>();
  ConfigService configService = locator<ConfigService>();
  ItemScrollController scrollController = ItemScrollController();

  int threadId;
  String? body;
  List<Uint8List> images = [];

  ReportCommentViewModel(this.threadId) {
    commentService.fetchComments(threadId);
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [commentService];

  List<Comment> get comments => commentService.comments;

  resolveImagePath(String path) {
    return configService.imageEndpoint + path;
  }

  setBody(String value) {
    body = value;
  }

  saveComment() async {
    if (body != null && body!.isNotEmpty) {
      setBusy(true);
      await commentService.submitComment(body!, threadId, images);

      body = null;
      images.clear();
      scrollController.jumpTo(index: comments.length - 1);

      setBusy(false);
    }
  }

  fetchComments() {
    commentService.fetchComments(threadId);
  }

  addImage(XFile? image) async {
    if (image != null) {
      var bytes = await image.readAsBytes();
      images.add(bytes);
      notifyListeners();
    }
  }
}
