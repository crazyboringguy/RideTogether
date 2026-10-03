import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../application/trips_controller.dart';
import '../domain/trip.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key, required this.controller, required this.tripId});

  final TripsController controller;
  final String tripId;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late Future<_TripDetails> _details;

  @override
  void initState() {
    super.initState();
    _details = _load();
  }

  Future<_TripDetails> _load() async {
    final results = await Future.wait<Object>([
      widget.controller.getTrip(widget.tripId),
      widget.controller.getMembers(widget.tripId),
    ]);
    return _TripDetails(
      results[0] as Trip,
      results[1] as List<TripMember>,
    );
  }

  Future<void> _refresh() async {
    setState(() => _details = _load());
    await _details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip details')),
      body: FutureBuilder<_TripDetails>(
        future: _details,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error! as ApiException).message
                : 'Unable to load this trip. Please try again.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refresh,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          final details = snapshot.requireData;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(details.trip.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('${details.trip.source} to ${details.trip.destination}'),
                const SizedBox(height: 16),
                SelectableText('Join code: ${details.trip.joinCode}'),
                const Divider(height: 32),
                Text('Members', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...details.members.map(
                  (member) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(member.name),
                    subtitle: Text(member.email),
                    trailing: Chip(label: Text(member.role)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TripDetails {
  const _TripDetails(this.trip, this.members);

  final Trip trip;
  final List<TripMember> members;
}
