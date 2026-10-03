import 'package:flutter/foundation.dart';

import '../../auth/application/auth_controller.dart';
import '../../../core/network/api_client.dart';
import '../data/trips_api.dart';
import '../domain/trip.dart';

class TripsController extends ChangeNotifier {
  TripsController({required AuthController authController, required TripsApi api})
      : _authController = authController,
        _api = api;

  final AuthController _authController;
  final TripsApi _api;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  List<Trip> _trips = [];
  List<Trip> get trips => List.unmodifiable(_trips);
  int _requestGeneration = 0;
  int _activeOperations = 0;

  Future<void> load() {
    final generation = ++_requestGeneration;
    return _run(generation, () async {
      final trips = await _api.list(_token);
      if (generation == _requestGeneration) _trips = trips;
    });
  }

  Future<Trip?> create({required String name, required String source, required String destination}) async {
    Trip? trip;
    final generation = ++_requestGeneration;
    await _run(generation, () async {
      trip = await _api.create(_token, name: name, source: source, destination: destination);
      final trips = await _api.list(_token);
      if (generation == _requestGeneration) _trips = trips;
    });
    return trip;
  }

  Future<Trip?> join(String joinCode) async {
    Trip? trip;
    final generation = ++_requestGeneration;
    await _run(generation, () async {
      trip = await _api.join(_token, joinCode);
      final trips = await _api.list(_token);
      if (generation == _requestGeneration) _trips = trips;
    });
    return trip;
  }

  Future<Trip> getTrip(String tripId) => _api.get(_token, tripId);
  Future<List<TripMember>> getMembers(String tripId) => _api.members(_token, tripId);

  String get _token {
    final token = _authController.accessToken;
    if (token == null) throw StateError('Authentication is required.');
    return token;
  }

  Future<void> _run(int generation, Future<void> Function() operation) async {
    _activeOperations += 1;
    _isLoading = true;
    if (generation == _requestGeneration) _errorMessage = null;
    notifyListeners();
    try {
      await operation();
    } on ApiException catch (error) {
      if (generation == _requestGeneration) _errorMessage = error.message;
    } on StateError catch (error) {
      if (generation == _requestGeneration) _errorMessage = error.message;
    } catch (_) {
      if (generation == _requestGeneration) {
        _errorMessage = 'Unable to complete that request.';
      }
    } finally {
      _activeOperations -= 1;
      _isLoading = _activeOperations > 0;
      notifyListeners();
    }
  }
}
