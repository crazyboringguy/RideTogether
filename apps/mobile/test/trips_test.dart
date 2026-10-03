import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ride_together/core/network/api_client.dart';
import 'package:ride_together/features/auth/application/auth_controller.dart';
import 'package:ride_together/features/auth/data/auth_api.dart';
import 'package:ride_together/features/auth/data/auth_session_store.dart';
import 'package:ride_together/features/auth/domain/user.dart';
import 'package:ride_together/features/trips/application/trips_controller.dart';
import 'package:ride_together/features/trips/data/trips_api.dart';
import 'package:ride_together/features/trips/domain/trip.dart';
import 'package:ride_together/features/trips/presentation/create_trip_screen.dart';
import 'package:ride_together/features/trips/presentation/join_trip_screen.dart';
import 'package:ride_together/features/trips/presentation/trip_details_screen.dart';
import 'package:ride_together/features/trips/presentation/trips_screen.dart';

import 'test_app.dart';

class _FakeAuthApi implements AuthApi {
  final User _user = User(
    id: 'user-1',
    name: 'Asha Rider',
    email: 'asha@example.com',
    createdAt: DateTime(2026),
  );

  @override
  Future<User> currentUser(String token) async => _user;

  @override
  Future<AuthResponse> login({required String email, required String password}) async =>
      AuthResponse(user: _user, token: 'test-token');

  @override
  Future<void> logout(String token) async {}

  @override
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async =>
      AuthResponse(user: _user, token: 'test-token');
}

class _FakeSessionStore implements AuthSessionStore {
  @override
  Future<void> clearToken() async {}

  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> writeToken(String token) async {}
}

class _FakeTripsApi implements TripsApi {
  final List<Trip> _trips = [];

  Trip _trip({String id = 'trip-1', String name = 'Coastal ride'}) => Trip(
        id: id,
        hostUserId: 'user-1',
        name: name,
        source: 'Mumbai',
        destination: 'Goa',
        joinCode: 'ABCDEFG2',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        role: 'host',
      );

  @override
  Future<Trip> create(
    String token, {
    required String name,
    required String source,
    required String destination,
  }) async {
    final trip = _trip(name: name);
    _trips.add(trip);
    return trip;
  }

  @override
  Future<Trip> get(String token, String tripId) async => _trips.single;

  @override
  Future<Trip> join(String token, String joinCode) async {
    final trip = _trip();
    _trips.add(trip);
    return trip;
  }

  @override
  Future<List<Trip>> list(String token) async => List.of(_trips);

  @override
  Future<List<TripMember>> members(String token, String tripId) async => [
        TripMember(
          id: 'user-1',
          name: 'Asha Rider',
          email: 'asha@example.com',
          role: 'host',
          joinedAt: DateTime(2026),
        ),
      ];
}

class _DelayedFirstListTripsApi extends _FakeTripsApi {
  final firstList = Completer<List<Trip>>();
  var listCalls = 0;

  @override
  Future<List<Trip>> list(String token) {
    listCalls += 1;
    return listCalls == 1 ? firstList.future : super.list(token);
  }
}

class _FailingCreateTripsApi extends _FakeTripsApi {
  @override
  Future<Trip> create(
    String token, {
    required String name,
    required String source,
    required String destination,
  }) =>
      throw const ApiException('Trip could not be created.', 400);
}

Future<AuthController> _authenticatedController() async {
  final controller = AuthController(
    api: _FakeAuthApi(),
    sessionStore: _FakeSessionStore(),
  );
  await controller.login(email: 'asha@example.com', password: 'safe-password-123');
  return controller;
}

void main() {
  test('trip controller creates and reloads the current user trips', () async {
    final api = _FakeTripsApi();
    final controller = TripsController(
      authController: await _authenticatedController(),
      api: api,
    );

    final trip = await controller.create(
      name: 'Coastal ride',
      source: 'Mumbai',
      destination: 'Goa',
    );

    expect(trip?.name, 'Coastal ride');
    expect(controller.trips, hasLength(1));
    expect(controller.trips.single.role, 'host');
  });

  test('a stale initial load cannot overwrite a newer create result', () async {
    final api = _DelayedFirstListTripsApi();
    final controller = TripsController(
      authController: await _authenticatedController(),
      api: api,
    );

    final initialLoad = controller.load();
    await controller.create(
      name: 'Coastal ride',
      source: 'Mumbai',
      destination: 'Goa',
    );
    api.firstList.complete([]);
    await initialLoad;

    expect(controller.trips.single.name, 'Coastal ride');
  });

  testWidgets('trips screen renders authenticated user trips', (tester) async {
    final api = _FakeTripsApi();
    await api.create(
      'test-token',
      name: 'Coastal ride',
      source: 'Mumbai',
      destination: 'Goa',
    );
    await tester.pumpWidget(
      TestApp(
        child: TripsScreen(
          authController: await _authenticatedController(),
          api: api,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My trips'), findsOneWidget);
    expect(find.text('Coastal ride'), findsOneWidget);
    expect(find.text('Mumbai to Goa'), findsOneWidget);
  });

  testWidgets('create and join forms validate required input', (tester) async {
    final controller = TripsController(
      authController: await _authenticatedController(),
      api: _FakeTripsApi(),
    );
    await tester.pumpWidget(TestApp(child: CreateTripScreen(controller: controller)));
    await tester.tap(find.widgetWithText(FilledButton, 'Create trip'));
    await tester.pump();
    expect(find.text('Enter at least 2 characters.'), findsNWidgets(3));

    await tester.pumpWidget(TestApp(child: JoinTripScreen(controller: controller)));
    await tester.tap(find.widgetWithText(FilledButton, 'Join trip'));
    await tester.pump();
    expect(find.text('Enter the 8-character join code.'), findsOneWidget);
  });

  testWidgets('create screen surfaces a safe trip API error', (tester) async {
    final controller = TripsController(
      authController: await _authenticatedController(),
      api: _FailingCreateTripsApi(),
    );
    await tester.pumpWidget(TestApp(child: CreateTripScreen(controller: controller)));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Coastal ride');
    await tester.enterText(fields.at(1), 'Mumbai');
    await tester.enterText(fields.at(2), 'Goa');
    await tester.tap(find.widgetWithText(FilledButton, 'Create trip'));
    await tester.pump();

    expect(find.text('Trip could not be created.'), findsOneWidget);
  });

  testWidgets('trip details render trip and member information', (tester) async {
    final api = _FakeTripsApi();
    final trip = await api.create(
      'test-token',
      name: 'Coastal ride',
      source: 'Mumbai',
      destination: 'Goa',
    );
    final controller = TripsController(
      authController: await _authenticatedController(),
      api: api,
    );
    await tester.pumpWidget(
      TestApp(child: TripDetailsScreen(controller: controller, tripId: trip.id)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Coastal ride'), findsOneWidget);
    expect(find.text('Asha Rider'), findsOneWidget);
    expect(find.text('host'), findsOneWidget);
  });
}
