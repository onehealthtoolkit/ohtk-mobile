// ignore_for_file: library_private_types_in_public_api
part of application_keys;

/// Widget keys for the Login screen.
///
/// Access via [ApplicationKeys.loginKeys] or the [K] typedef:
///   K.loginKeys.view
///   K.loginKeys.usernameField
final class _LoginKeys {
  _LoginKeys._();

  /// The root [Scaffold] of LoginView.
  final Key view = const Key('login_view');

  /// The [TextField] for username input.
  final Key usernameField = const Key('login_username_field');

  /// The [TextField] for password input.
  final Key passwordField = const Key('login_password_field');

  /// The primary "Sign In" [ElevatedButton].
  final Key signInButton = const Key('login_sign_in_button');

  /// The QR-code sign-in button.
  final Key qrSignInButton = const Key('login_qr_sign_in_button');

  /// The "Change Server" tappable in the server footer.
  final Key changeServerButton = const Key('login_change_server_button');
}
