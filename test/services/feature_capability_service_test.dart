import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/api/feature_capability_api.dart';
import 'package:podd_app/services/feature_capability_service.dart';

class _FakeFeatureCapabilityApi extends FeatureCapabilityApi {
  bool? nextValue;
  Object? errorToThrow;

  _FakeFeatureCapabilityApi()
      : super(() =>
            GraphQLClient(link: const _UnusedLink(), cache: GraphQLCache()));

  @override
  Future<bool> fetchVillageEnabled() async {
    final error = errorToThrow;
    if (error != null) {
      throw error;
    }
    return nextValue ?? false;
  }
}

class _UnusedLink extends Link {
  const _UnusedLink();

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    return const Stream.empty();
  }
}

void main() {
  late _FakeFeatureCapabilityApi api;
  late FeatureCapabilityService service;

  setUpAll(() {
    if (!locator.isRegistered<Logger>()) {
      locator.registerSingleton<Logger>(Logger());
    }
  });

  setUp(() {
    api = _FakeFeatureCapabilityApi();
    service = FeatureCapabilityService(api: api, logger: Logger());
  });

  test('refresh stores a successful village capability', () async {
    api.nextValue = true;

    await service.refresh();

    expect(service.villageEnabled, isTrue);
    expect(service.villageCapabilityKnown, isTrue);
  });

  test('refresh keeps the last village capability when the network fails',
      () async {
    api.nextValue = true;
    await service.refresh();

    api.errorToThrow = Exception('network down');
    await service.refresh();

    expect(service.villageEnabled, isTrue);
    expect(service.villageCapabilityKnown, isTrue);
  });

  test('refresh still records a successful disabled capability', () async {
    api.nextValue = true;
    await service.refresh();

    api.nextValue = false;
    await service.refresh();

    expect(service.villageEnabled, isFalse);
    expect(service.villageCapabilityKnown, isTrue);
  });

  test('reset still clears village capability', () async {
    api.nextValue = true;
    await service.refresh();

    service.reset();

    expect(service.villageEnabled, isFalse);
    expect(service.villageCapabilityKnown, isFalse);
  });
}
