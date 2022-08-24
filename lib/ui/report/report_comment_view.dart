import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/ui/report/report_comment_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';

class ReportCommentView extends StatelessWidget {
  final int threadId;
  const ReportCommentView(this.threadId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportCommentViewModel>.reactive(
      viewModelBuilder: () => ReportCommentViewModel(threadId),
      builder: (context, viewModel, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Comments'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await viewModel.fetchComments();
                    },
                    child: _CommentList(),
                  ),
                ),
                _CommentForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentList extends HookViewModelWidget<ReportCommentViewModel> {
  final formatter = DateFormat("dd/MM/yyyy HH:mm");

  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportCommentViewModel viewModel) {
    if (viewModel.comments.isNotEmpty) {
      return ScrollablePositionedList.builder(
        initialScrollIndex: viewModel.comments.length - 1,
        itemScrollController: viewModel.scrollController,
        itemCount: viewModel.comments.length,
        itemBuilder: (context, index) {
          var comment = viewModel.comments[index];

          return Card(
            shadowColor: Colors.transparent,
            color: Colors.transparent,
            child: ListTile(
              leading: _user(viewModel, comment),
              title: _body(viewModel, comment),
            ),
          );
        },
      );
    }
    return const Align(
      alignment: Alignment.topCenter,
      child: Text("No comments"),
    );
  }

  Widget _user(ReportCommentViewModel viewModel, Comment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: comment.user.avatarUrl != null
              ? CachedNetworkImage(
                  width: 30,
                  imageUrl: viewModel.resolveImagePath(comment.user.avatarUrl!),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                )
              : Container(
                  color: Colors.black45,
                  width: 30,
                  height: 30,
                ),
        ),
        SizedBox(
          width: 50,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              comment.user.username,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: .9,
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(ReportCommentViewModel viewModel, Comment comment) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.body),
          const SizedBox(height: 8),
          _attachmentList(viewModel, comment),
          Align(
            alignment: Alignment.topRight,
            child: Text(
              formatter.format(comment.createdAt),
              style: TextStyle(color: Colors.grey[500]),
              textScaleFactor: .75,
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentList(ReportCommentViewModel viewModel, Comment comment) {
    return comment.attachments.isNotEmpty
        ? GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              // width / height: fixed for *all* items
              childAspectRatio: 1,
            ),
            itemCount: comment.attachments.length,
            itemBuilder: (context, index) {
              var attachment = comment.attachments[index];
              return CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: viewModel.resolveImagePath(
                    attachment.thumbnailPath ?? attachment.filePath),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
              );
            },
          )
        : const SizedBox.shrink();
  }
}

class _CommentForm extends HookViewModelWidget<ReportCommentViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportCommentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: Colors.grey[100],
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _attachImageButton(context, viewModel),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              children: [
                _imageList(viewModel),
                const SizedBox(height: 8),
                _commentField(viewModel),
              ],
            ),
          ),
          const SizedBox(width: 5),
          _sendButton(viewModel),
        ],
      ),
    );
  }

  Widget _attachImageButton(
      BuildContext context, ReportCommentViewModel viewModel) {
    return InkWell(
      onTap: () => _showAddImageModal(context, viewModel),
      child: const SizedBox(
        height: 40,
        width: 30,
        child: Align(
          alignment: Alignment.center,
          child: Icon(Icons.add_a_photo),
        ),
      ),
    );
  }

  _showAddImageModal(BuildContext context, ReportCommentViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                var image = await _pickImage(ImageSource.gallery);
                if (image != null) {
                  viewModel.addImage(image);
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a Photo'),
              onTap: () async {
                var image = await _pickImage(ImageSource.camera);
                if (image != null) {
                  viewModel.addImage(image);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    var picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: source);
      return image;
    } catch (e) {
      debugPrint("$e");
    }
    return null;
  }

  _imageList(ReportCommentViewModel viewModel) {
    return viewModel.images.isNotEmpty
        ? GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              // width / height: fixed for *all* items
              childAspectRatio: 1,
            ),
            itemCount: viewModel.images.length,
            itemBuilder: (context, index) {
              var image = viewModel.images[index];
              return Image.memory(image, fit: BoxFit.cover);
            },
          )
        : const SizedBox.shrink();
  }

  Widget _sendButton(ReportCommentViewModel viewModel) {
    return ElevatedButton(
      onPressed: () async {
        await viewModel.saveComment();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: viewModel.isBusy
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            )
          : const Text("Send"),
    );
  }

  Widget _commentField(ReportCommentViewModel viewModel) {
    var body = useTextEditingController();
    if (viewModel.body == null) {
      body.clear();
    }

    return TextField(
      controller: body,
      onChanged: viewModel.setBody,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 4,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
    );
  }
}
