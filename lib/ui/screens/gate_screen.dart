import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../access/gate_controller.dart';

class GateScreen extends StatefulWidget {
  final GateController gate;
  final Future<bool> Function(Uint8List dek) onDekReady;

  const GateScreen({super.key, required this.gate, required this.onDekReady});

  @override
  State<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<GateScreen> {
  final _pin = TextEditingController();
  bool _busy = false;
  bool _biometricsAvailable = false;
  int? _retryAfterSeconds;

  @override
  void initState() {
    super.initState();
    _loadBiometricsAvailability();
  }

  Future<void> _loadBiometricsAvailability() async {
    final ok = await widget.gate.canUseBiometrics;
    if (mounted) setState(() => _biometricsAvailable = ok);
  }

  Future<void> _handleGate(Future<GateDecision> Function() action) async {
    setState(() {
      _busy = true;
      _retryAfterSeconds = null;
    });
    final decision = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (decision.unlocked) {
      final dek = await widget.gate.retrieveDekForUnlock();
      if (dek != null) {
        await widget.onDekReady(dek);
      }
      return;
    }
    setState(() {
      _retryAfterSeconds = decision.retryAfterSeconds > 0
          ? decision.retryAfterSeconds
          : null;
      _pin.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.lock, size: 64),
                const SizedBox(height: 8),
                Text('Unlock mySecrets',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextField(
                  controller: _pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  readOnly: _busy,
                  onSubmitted: (_) => _submitPin(),
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    errorText: _retryAfterSeconds == null
                        ? null
                        : 'Too many attempts — wait $_retryAfterSeconds s',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _submitPin,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Unlock with PIN'),
                ),
                if (_biometricsAvailable) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _submitBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use biometrics'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitPin() async {
    if (_pin.text.length != 6) return;
    await _handleGate(() => widget.gate.unlockWithPin(_pin.text));
  }

  Future<void> _submitBiometrics() async {
    await _handleGate(widget.gate.unlockWithBiometrics);
  }
}
