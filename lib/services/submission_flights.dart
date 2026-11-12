import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';

/// Coalesce a second tap/drain for the same persisted item.
class SubmissionFlights<T> {
  final _pending = <String, Future<T>>{};

  Future<T> run(String id, Future<T> Function() submit) {
    return _pending.putIfAbsent(id, () async {
      final watch = Stopwatch()..start();
      String outcome = 'exception';
      try {
        final result = await submit();
        outcome = result.runtimeType.toString();
        return result;
      } finally {
        if (locator.isRegistered<Logger>()) {
          locator<Logger>().i({
            'event': 'submission',
            'localId': id,
            'stage': T.toString(),
            'outcome': outcome,
            'durationMs': watch.elapsedMilliseconds
          });
        }
        _pending.remove(id);
      }
    });
  }
}
