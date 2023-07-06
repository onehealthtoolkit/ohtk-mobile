import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/fcm_register_result.dart';
import 'package:podd_app/models/entities/user_message.dart';
import 'package:podd_app/services/api/notification_api.dart';
import 'package:stacked/stacked.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}

typedef NotificationMessageCallback = void Function(String userMessageId);

abstract class INotificationService with ListenableServiceMixin {
  final _logger = locator<Logger>();

  List<UserMessage> get userMessages;

  setupFirebaseMessaging(
    String userId, {
    NotificationMessageCallback? onInitialMessage,
    NotificationMessageCallback? onMessageOpenedApp,
    NotificationMessageCallback? onForegroundMessage,
  });

  fetchMyMessages(bool resetFlag);

  Future<UserMessage> getMyMessage(String id);

  bool get hasUnseenMessages;
}

class NotificationService extends INotificationService {
  final _notificationApi = locator<NotificationApi>();

  final ReactiveList<UserMessage> _userMessages = ReactiveList<UserMessage>();

  final ReactiveValue<bool> _hasUnseenMessages = ReactiveValue<bool>(false);

  int userMessageLimit = 20;
  bool hasMoreUserMessages = false;
  int currentUserMessageNextOffset = 0;

  NotificationService() {
    listenToReactiveValues([_userMessages, _hasUnseenMessages]);
  }

  @override
  List<UserMessage> get userMessages => _userMessages;

  @override
  bool get hasUnseenMessages => _hasUnseenMessages.value;

  @override
  setupFirebaseMessaging(
    String userId, {
    NotificationMessageCallback? onInitialMessage,
    NotificationMessageCallback? onMessageOpenedApp,
    NotificationMessageCallback? onForegroundMessage,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    _logger.d("register fcm token: ${fcmToken ?? "???"}");
    if (fcmToken == null) {
      return;
    }

    _registerFcmToken(userId, fcmToken);

    // Note: This callback is fired at each app startup and whenever a new
    // token is generated.
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      _logger.d("fcm token refresh: $fcmToken");
      _registerFcmToken(userId, fcmToken);
    }).onError((e) {
      _logger.e(e);
    });

    if (Platform.isIOS) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      var settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.d('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        _logger.d('User granted provisional permission');
      } else {
        _logger.d('User declined or has not accepted permission');
      }
    }

    // app in terminated state has been opened from notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      _logger.v("Open terminated app via notification message");

      if (message != null) {
        final userMessageId = message.data["user_message_id"];
        _logger.d("Data: user message id: ${message.data["user_message_id"]}");

        if (userMessageId != null && onInitialMessage != null) {
          onInitialMessage(userMessageId);
        }
      }
    });

    // app is in background (unterminated) and has been opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.v("Open background app via notification message");

      final userMessageId = message.data["user_message_id"];
      _logger.d("Data: user message id: ${message.data["user_message_id"]}");

      if (userMessageId != null && onMessageOpenedApp != null) {
        onMessageOpenedApp(userMessageId);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // app is already in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.v("Notification message received whilst in the foreground");

      final userMessageId = message.data["user_message_id"];
      _logger.d("Data: user message id: ${message.data["user_message_id"]}");

      if (userMessageId != null && onForegroundMessage != null) {
        // Show overlay notification
        onForegroundMessage(userMessageId);
        fetchMyMessages(true);
      }
    });
  }

  _registerFcmToken(String userId, String fcmToken) async {
    try {
      final result = await _notificationApi.registerFcmToken(userId, fcmToken);
      if (result is FcmTokenRegisterFailure) {
        _logger.e(result.messages);
      }
    } on LinkException catch (e) {
      _logger.e(e);
    }
  }

  _updateHasMoreUnseenMessages() {
    var unSeen = _userMessages.any((message) => !message.isSeen);
    _hasUnseenMessages.value = unSeen;
  }

  @override
  fetchMyMessages(bool resetFlag) async {
    if (resetFlag) {
      currentUserMessageNextOffset = 0;
      _userMessages.clear();
    }
    try {
      final result = await _notificationApi.fetchMyMessages(
        offset: currentUserMessageNextOffset,
        limit: userMessageLimit,
      );
      _userMessages.addAll(result.data);
      _updateHasMoreUnseenMessages();
      hasMoreUserMessages = result.hasNextPage;
      currentUserMessageNextOffset =
          currentUserMessageNextOffset + userMessageLimit;
    } catch (e) {
      // do nothing
    }
  }

  @override
  Future<UserMessage> getMyMessage(String id) async {
    final result = await _notificationApi.getMyMessage(id);
    // imply than this message should be seen
    _userMessages.firstWhere((message) => message.id == id).isSeen = true;
    _updateHasMoreUnseenMessages();
    return result.data;
  }
}
