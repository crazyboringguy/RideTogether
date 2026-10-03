import 'package:flutter/material.dart';

import '../../../core/configuration/api_configuration.dart';
import '../../../core/network/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../application/trips_controller.dart';
import '../data/trips_api.dart';
import '../domain/trip.dart';
import 'create_trip_screen.dart';
import 'join_trip_screen.dart';
import 'trip_details_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key, required this.authController, this.api});

  final AuthController authController;
  final TripsApi? api;

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  late final TripsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TripsController(
      authController: widget.authController,
      api: widget.api ??
          RestTripsApi(ApiClient(baseUrl: ApiConfiguration.baseUrl)),
    )..load();
  }

  Future<void> _openCreateTrip() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateTripScreen(controller: _controller),
      ),
    );
  }

  Future<void> _openJoinTrip() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JoinTripScreen(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('My trips'),
          actions: [
            IconButton(
              onPressed: _openJoinTrip,
              icon: const Icon(Icons.group_add_outlined),
              tooltip: 'Join trip',
            ),
            IconButton(
              onPressed: _openCreateTrip,
              icon: const Icon(Icons.add),
              tooltip: 'Create trip',
            ),
          ],
        ),
        body: _TripsBody(
          controller: _controller,
          onOpenTrip: (trip) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TripDetailsScreen(
                controller: _controller,
                tripId: trip.id,
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openCreateTrip,
          icon: const Icon(Icons.add),
          label: const Text('Create trip'),
        ),
      ),
    );
  }
}

class _TripsBody extends StatelessWidget {
  const _TripsBody({required this.controller, required this.onOpenTrip});

  final TripsController controller;
  final ValueChanged<Trip> onOpenTrip;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage != null && controller.trips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: controller.load,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    if (controller.trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No trips yet. Create a trip or join one with a join code.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: controller.trips.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final trip = controller.trips[index];
          return Card(
            child: ListTile(
              title: Text(trip.name),
              subtitle: Text('${trip.source} to ${trip.destination}'),
              trailing: trip.role == null ? null : Chip(label: Text(trip.role!)),
              onTap: () => onOpenTrip(trip),
            ),
          );
        },
      ),
    );
  }
}
