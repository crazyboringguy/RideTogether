import '../../../core/network/api_client.dart';
import '../domain/trip.dart';

abstract interface class TripsApi {
  Future<List<Trip>> list(String token);
  Future<Trip> create(String token, {required String name, required String source, required String destination});
  Future<Trip> join(String token, String joinCode);
  Future<Trip> get(String token, String tripId);
  Future<List<TripMember>> members(String token, String tripId);
}

class RestTripsApi implements TripsApi {
  RestTripsApi(this._client);

  final ApiClient _client;

  @override
  Future<List<Trip>> list(String token) async {
    final response = await _client.get('/trips', token: token);
    return (response['trips'] as List<dynamic>).cast<Map<String, dynamic>>().map(Trip.fromJson).toList();
  }

  @override
  Future<Trip> create(String token, {required String name, required String source, required String destination}) async {
    final response = await _client.post('/trips', token: token, body: {'name': name, 'source': source, 'destination': destination});
    return Trip.fromJson(response['trip'] as Map<String, dynamic>);
  }

  @override
  Future<Trip> join(String token, String joinCode) async {
    final response = await _client.post('/trips/join', token: token, body: {'joinCode': joinCode});
    return Trip.fromJson(response['trip'] as Map<String, dynamic>);
  }

  @override
  Future<Trip> get(String token, String tripId) async => Trip.fromJson((await _client.get('/trips/$tripId', token: token))['trip'] as Map<String, dynamic>);

  @override
  Future<List<TripMember>> members(String token, String tripId) async {
    final response = await _client.get('/trips/$tripId/members', token: token);
    return (response['members'] as List<dynamic>).cast<Map<String, dynamic>>().map(TripMember.fromJson).toList();
  }
}
