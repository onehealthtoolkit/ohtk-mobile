import 'package:stacked/stacked.dart';
import 'package:just_audio/just_audio.dart';

class PlayableReportFileViewModel extends BaseViewModel {
  final String type;
  final String url;

  late AudioPlayer _audioPlayer;
  late ProgressBarState progressState;
  late ButtonState buttonState;

  Duration position = Duration.zero;
  Duration bufferedPosition = Duration.zero;
  Duration duration = Duration.zero;

  PlayableReportFileViewModel(this.type, this.url) {
    _init();

    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonState = ButtonState.loading;
      } else if (!isPlaying) {
        buttonState = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonState = ButtonState.playing;
      } else {
        buttonState = ButtonState.done;
      }
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      this.position = position;
      progressState = ProgressBarState(
        current: position,
        buffered: bufferedPosition,
        total: duration,
      );
      notifyListeners();
    });

    _audioPlayer.playbackEventStream.listen((playbackEvent) {
      bufferedPosition = playbackEvent.bufferedPosition;
      duration = playbackEvent.duration ?? Duration.zero;
      progressState = ProgressBarState(
        current: position,
        buffered: bufferedPosition,
        total: duration,
      );
      notifyListeners();
    });
  }

  void _init() async {
    progressState = ProgressBarState(
      current: position,
      buffered: bufferedPosition,
      total: duration,
    );
    buttonState = ButtonState.paused;

    _audioPlayer = AudioPlayer();
    // sample https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3
    await _audioPlayer.setUrl(url);
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading, done }
