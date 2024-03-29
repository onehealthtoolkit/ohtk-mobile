import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/ui/report/report_comment_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportCommentView extends StatelessWidget {
  final int threadId;
  const ReportCommentView(this.threadId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportCommentViewModel>.reactive(
      viewModelBuilder: () => ReportCommentViewModel(threadId),
      builder: (context, viewModel, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Scaffold(
            body: Column(
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

class _CommentList extends StackedHookView<ReportCommentViewModel> {
  final AppTheme appTheme = locator<AppTheme>();
  final formatter = DateFormat("dd/MM/yyyy HH:mm");

  @override
  Widget builder(BuildContext context, ReportCommentViewModel viewModel) {
    if (viewModel.comments.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: ScrollablePositionedList.builder(
          initialScrollIndex: viewModel.comments.length - 1,
          itemScrollController: viewModel.scrollController,
          itemCount: viewModel.comments.length,
          itemBuilder: (context, index) {
            var comment = viewModel.comments[index];

            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: _user(viewModel, comment, context),
                title: _body(viewModel, comment, context),
              ),
            );
          },
        ),
      );
    }
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noComment,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w300,
            ),
      ),
    );
  }

  Widget _user(
      ReportCommentViewModel viewModel, Comment comment, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: comment.user.avatarUrl != null
              ? CachedNetworkImage(
                  cacheKey: 'user-avatar-${comment.user.id}',
                  width: 30,
                  imageUrl: viewModel.resolveImagePath(comment.user.avatarUrl!),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                )
              : Container(
                  color: appTheme.sub4,
                  width: 40,
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: appTheme.sub3.withAlpha(100),
                    ),
                  ),
                ),
        ),
        Expanded(
          child: SizedBox(
            width: 70,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                comment.user.username,
                overflow: TextOverflow.ellipsis,
                textScaleFactor: .9,
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(
      ReportCommentViewModel viewModel, Comment comment, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatter.format(comment.createdAt.toLocal()),
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 10.sp, color: appTheme.sub2),
          ),
          Text(
            comment.body,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 12.sp,
                ),
          ),
          const SizedBox(height: 8),
          _attachmentList(viewModel, comment),
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

class _CommentForm extends StackedHookView<ReportCommentViewModel> {
  final AppTheme apptheme = locator<AppTheme>();

  @override
  Widget builder(BuildContext context, ReportCommentViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        boxShadow: [
          const BoxShadow(
            color: Colors.black38,
            blurRadius: 5.0,
            offset: Offset(0.0, 0.75),
          ),
          BoxShadow(
            color: apptheme.bg2,
            offset: const Offset(0.0, 8),
          ),
        ],
        color: apptheme.bg2,
      ),
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
                _commentField(viewModel),
              ],
            ),
          ),
          const SizedBox(width: 15),
          _sendButton(context, viewModel),
        ],
      ),
    );
  }

  Widget _attachImageButton(
      BuildContext context, ReportCommentViewModel viewModel) {
    return InkWell(
      onTap: () => _showAddImageModal(context, viewModel),
      child: SizedBox(
        height: 50,
        width: 50,
        child: Align(
          alignment: Alignment.center,
          child: SvgPicture.asset(
            "assets/images/add_image_comment_icon.svg",
            colorFilter: ColorFilter.mode(
                Theme.of(context).primaryColor, BlendMode.srcIn),
            width: 40,
          ),
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
                if (context.mounted) {
                  Navigator.pop(context);
                }
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
                if (context.mounted) {
                  Navigator.pop(context);
                }
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

  Widget _sendButton(BuildContext context, ReportCommentViewModel viewModel) {
    return FlatButton.primary(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      onPressed: () async {
        await viewModel.saveComment();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: viewModel.isBusy
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Text(
              AppLocalizations.of(context)!.sendButton,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
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
    );
  }
}
