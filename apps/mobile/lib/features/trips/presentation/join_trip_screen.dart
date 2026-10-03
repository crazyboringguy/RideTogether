import 'package:flutter/material.dart';

import '../application/trips_controller.dart';

class JoinTripScreen extends StatefulWidget {
  const JoinTripScreen({super.key, required this.controller});

  final TripsController controller;

  @override
  State<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends State<JoinTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final trip = await widget.controller.join(_joinCodeController.text.trim());
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
      appBar: AppBar(title: const Text('Join trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _joinCodeController,
              decoration: const InputDecoration(labelText: 'Join code'),
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              maxLength: 8,
              validator: (value) => value == null || value.trim().length != 8
                  ? 'Enter the 8-character join code.'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) => FilledButton(
                onPressed: widget.controller.isLoading ? null : _submit,
                child: Text(widget.controller.isLoading ? 'Joining…' : 'Join trip'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
