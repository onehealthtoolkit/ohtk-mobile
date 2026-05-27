/// Central hub for all Widget Keys used in Patrol integration tests.
///
/// Each feature has its own `_keys.dart` part-file so key lists stay small.
/// Usage from anywhere:
///   import 'package:podd_app/keys/application_keys.dart';
///   // then: K.loginKeys.usernameField
library application_keys;

import 'package:flutter/widgets.dart';

part 'items/login_keys.dart';

/// Top-level typedef so callers can write `K.loginKeys.xxx` instead of the
/// full `ApplicationKeys.loginKeys.xxx`.
typedef K = ApplicationKeys;

final class ApplicationKeys {
  const ApplicationKeys._();

  static final loginKeys = _LoginKeys._();
}
