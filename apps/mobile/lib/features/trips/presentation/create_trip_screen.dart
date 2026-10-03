import 'package:flutter/material.dart';

import '../application/trips_controller.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key, required this.controller});

  final TripsController controller;

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final trip = await widget.controller.create(
      name: _nameController.text.trim(),
      source: _sourceController.text.trim(),
      destination: _destinationController.text.trim(),
    );
    if (!mounted) return;
    if (trip != null) {
      Navigator.of(context).pop();
    } else if (widget.controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.controller.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Trip name'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(labelText: 'Source'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Destination'),
              textInputAction: TextInputAction.done,
              validator: _required,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) => FilledButton(
                onPressed: widget.controller.isLoading ? null : _submit,
                child: Text(widget.controller.isLoading ? 'Creating…' : 'Create trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().length < 2
        ? 'Enter at least 2 characters.'
        : null;
  }
}
