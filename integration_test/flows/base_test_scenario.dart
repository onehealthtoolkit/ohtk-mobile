import 'package:flutter/foundation.dart';
import 'package:patrol/patrol.dart';

/// Abstract base for all Patrol test scenarios.
///
/// Inspired by the Chain of Responsibility pattern described in:
/// https://vbacik-10.medium.com/patrol-driven-ui-test-architecture-for-flutter-2e92923cfa49
///
/// Every screen / feature flow extends this class. Flows are linked via
/// [next], and the chain executes sequentially when [startFlow] is called
/// on the first scenario.
///
/// ```
/// LoginScenario($, next: HomeScenario($, next: null))
///   ..startFlow();
/// ```
abstract class BaseTestScenario {
  /// The Patrol test driver — the `$` tester passed from [patrolTest].
  final PatrolIntegrationTester $;

  /// Optional next scenario to run after this one completes successfully.
  final BaseTestScenario? next;

  BaseTestScenario(this.$, {this.next});

  /// Main test logic for this scenario.
  ///
  /// Return `true` to signal success and allow the chain to continue;
  /// return `false` to halt the chain early.
  Future<bool> run();

  /// Guard that decides whether this scenario should execute.
  ///
  /// Return `true` to run, `false` to skip (the chain still advances to
  /// [next]).  Use this to skip screens that are only shown once (e.g.
  /// onboarding) or that are guarded by feature flags.
  Future<bool> waitAndCheckValid();

  /// Starts this scenario and, when done, hands off to [next].
  ///
  /// Call this on the *first* scenario in your chain from [patrolTest].
  Future<void> startFlow() async {
    debugPrint('[PatrolFlow] ▶ Checking: $runtimeType');
    final isValid = await waitAndCheckValid();

    if (isValid) {
      debugPrint('[PatrolFlow] ▶ Running:  $runtimeType');
      final success = await run();
      if (!success) {
        debugPrint('[PatrolFlow] ✗ Halted:  $runtimeType returned false');
        return;
      }
      debugPrint('[PatrolFlow] ✓ Done:    $runtimeType');
    } else {
      debugPrint('[PatrolFlow] ⏭ Skipped: $runtimeType (not valid)');
    }

    if (next != null) {
      await next!.startFlow();
    }
  }
}
