import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/report/report_comment_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

final _commentTimestamp = DateFormat('dd/MM/yy HH:mm');
Color get _brandPrimary => OhtkTheme.palette.teal700;
Color get _brandTint => OhtkTheme.palette.teal700.withValues(alpha: 0.08);

class ReportCommentView extends StatelessWidget {
  final int threadId;

  const ReportCommentView(this.threadId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportCommentViewModel>.reactive(
      viewModelBuilder: () => ReportCommentViewModel(threadId),
      builder: (context, viewModel, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
            _CommentComposer(),
          ],
        ),
      ),
    );
  }
}

class _CommentList extends StackedHookView<ReportCommentViewModel> {
  @override
  Widget builder(BuildContext context, ReportCommentViewModel viewModel) {
    final comments = viewModel.comments;
    if (comments.isEmpty) {
      return _CommentEmptyState();
    }
    return ScrollablePositionedList.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      initialScrollIndex: comments.length - 1,
      itemScrollController: viewModel.scrollController,
      itemCount: comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _CommentCard(
          comment: comments[index],
          resolveImagePath: viewModel.resolveImagePath,
        );
      },
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;
  final dynamic Function(String) resolveImagePath;

  const _CommentCard({
    required this.comment,
    required this.resolveImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final attachments = comment.attachments;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: incidentsHair),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(
            avatarUrl: comment.user.avatarUrl,
            name: comment.user.username,
            resolveImagePath: resolveImagePath,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        comment.user.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: incidentsInk,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _commentTimestamp.format(comment.createdAt.toLocal()),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: incidentsMuted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.body,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: incidentsBody,
                  ),
                ),
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1,
                    ),
                    itemCount: attachments.length,
                    itemBuilder: (context, index) {
                      final attach = attachments[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: resolveImagePath(
                              attach.thumbnailPath ?? attach.filePath),
                          placeholder: (context, url) =>
                              Container(color: incidentsHair),
                          errorWidget: (context, url, error) => Container(
                            color: OhtkTheme.palette.teal100,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: incidentsMuted,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final dynamic Function(String) resolveImagePath;

  const _Avatar({
    required this.avatarUrl,
    required this.name,
    required this.resolveImagePath,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CachedNetworkImage(
            imageUrl: resolveImagePath(avatarUrl!),
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: incidentsHair),
            errorWidget: (context, url, error) => _initialFallback(),
          ),
        ),
      );
    }
    return _initialFallback();
  }

  Widget _initialFallback() {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _brandPrimary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _brandPrimary,
        ),
      ),
    );
  }
}

class _CommentEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _brandTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 32,
              color: _brandPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          localize.noCommentsTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: incidentsInk,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          localize.noCommentsHelper,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: incidentsMuted,
          ),
        ),
      ],
    );
  }
}

class _CommentComposer extends StackedHookView<ReportCommentViewModel> {
  @override
  Widget builder(BuildContext context, ReportCommentViewModel viewModel) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final isFocused = useState(false);
    final hasText = useState(controller.text.trim().isNotEmpty);

    useEffect(() {
      void onFocus() => isFocused.value = focusNode.hasFocus;
      focusNode.addListener(onFocus);
      return () => focusNode.removeListener(onFocus);
    }, [focusNode]);

    useEffect(() {
      void onChange() {
        hasText.value = controller.text.trim().isNotEmpty;
      }

      controller.addListener(onChange);
      return () => controller.removeListener(onChange);
    }, [controller]);

    // Mirror controller text back into the view-model, and clear on submit.
    useEffect(() {
      if (viewModel.body == null && controller.text.isNotEmpty) {
        controller.clear();
      }
      return null;
    });

    final localize = AppLocalizations.of(context)!;
    final canSend = hasText.value && !viewModel.isBusy;
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: incidentsHair)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.images.isNotEmpty) ...[
            _PendingImagesGrid(images: viewModel.images),
            const SizedBox(height: 8),
          ],
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: incidentsSand,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isFocused.value ? _brandPrimary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ComposerIcon(
                  icon: Icons.camera_alt_outlined,
                  tone: _brandPrimary,
                  onTap: () => _showAddImageModal(context, viewModel),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: viewModel.setBody,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 15,
                        color: incidentsInk,
                        height: 1.3,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: localize.commentPlaceholder,
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: incidentsMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                _ComposerSend(
                  enabled: canSend,
                  busy: viewModel.isBusy,
                  onPressed: () async {
                    await viewModel.saveComment();
                    controller.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddImageModal(
      BuildContext context, ReportCommentViewModel viewModel) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  final image = await _pickImage(ImageSource.gallery);
                  if (image != null) viewModel.addImage(image);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a Photo'),
                onTap: () async {
                  final image = await _pickImage(ImageSource.camera);
                  if (image != null) viewModel.addImage(image);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      return await ImagePicker().pickImage(source: source);
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }
}

class _ComposerIcon extends StatelessWidget {
  final IconData icon;
  final Color tone;
  final VoidCallback onTap;

  const _ComposerIcon({
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      color: tone,
      splashRadius: 22,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: onTap,
    );
  }
}

class _ComposerSend extends StatelessWidget {
  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  const _ComposerSend({
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_brandPrimary),
            ),
          ),
        ),
      );
    }
    return IconButton(
      icon: const Icon(Icons.send_rounded, size: 22),
      color: _brandPrimary,
      disabledColor: _brandPrimary.withValues(alpha: 0.35),
      splashRadius: 22,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: enabled ? onPressed : null,
    );
  }
}

class _PendingImagesGrid extends StatelessWidget {
  final List images;

  const _PendingImagesGrid({required this.images});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(images[index], fit: BoxFit.cover),
        );
      },
    );
  }
}
