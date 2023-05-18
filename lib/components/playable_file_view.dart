import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/playable_file_view_model.dart';
import 'package:podd_app/locator.dart';
import 'package:stacked/stacked.dart';

class PlayableReportFileView extends HookWidget {
  final String type;
  final String url;
  final AppTheme appTheme = locator<AppTheme>();

  PlayableReportFileView({Key? key, required this.type, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PlayableReportFileViewModel>.nonReactive(
      viewModelBuilder: () => PlayableReportFileViewModel(type, url),
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: appTheme.bg1,
          body: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: appTheme.bg1.withOpacity(0),
              constraints: BoxConstraints.expand(
                height: MediaQuery.of(context).size.height,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Progress(),
                  _Control(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Progress extends ViewModelWidget<PlayableReportFileViewModel> {
  @override
  Widget build(BuildContext context, PlayableReportFileViewModel viewModel) {
    final state = viewModel.progressState;
    return ProgressBar(
      progress: state.current,
      buffered: state.buffered,
      total: state.total,
      onSeek: viewModel.seek,
      timeLabelLocation: TimeLabelLocation.below,
      timeLabelType: TimeLabelType.totalTime,
      timeLabelTextStyle: const TextStyle(fontSize: 24, color: Colors.white),
    );
  }
}

class _Control extends ViewModelWidget<PlayableReportFileViewModel> {
  @override
  Widget build(BuildContext context, PlayableReportFileViewModel viewModel) {
    final state = viewModel.buttonState;
    switch (state) {
      case ButtonState.loading:
        return Container(
          margin: const EdgeInsets.all(8.0),
          width: 32.0,
          height: 32.0,
          child: const CircularProgressIndicator(),
        );
      case ButtonState.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: 32.0,
          onPressed: () {
            viewModel.play();
          },
        );
      case ButtonState.playing:
        return IconButton(
          icon: const Icon(Icons.pause),
          iconSize: 32.0,
          onPressed: () {
            viewModel.pause();
          },
        );
      case ButtonState.done:
        return IconButton(
          icon: const Icon(Icons.replay),
          iconSize: 32.0,
          onPressed: () {
            viewModel.seek(Duration.zero);
          },
        );
    }
  }
}
