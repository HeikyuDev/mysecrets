import 'package:flutter/material.dart';

class EnrollGateScreen extends StatefulWidget {
  final bool biometricsAvailable;
  final Future<void> Function(String pin) onEnroll;

  const EnrollGateScreen({
    super.key,
    required this.biometricsAvailable,
    required this.onEnroll,
  });

  @override
  State<EnrollGateScreen> createState() => _EnrollGateScreenState();
}

class _EnrollGateScreenState extends State<EnrollGateScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  void _goNext(String value, {required bool isConfirm}) {
    if (value.length != 6) return;
    setState(() {
      if (isConfirm) {
        _confirm.text = value;
      } else {
        _pin.text = value;
      }
    });
  }

  Future<void> _submit() async {
    if (_pin.text.length != 6 || _confirm.text.length != 6) return;
    if (_pin.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onEnroll(_pin.text);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enrollment failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Quick unlock',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                const Text(
                  'Choose a 6-digit PIN to unlock instantly. '
                  'This PIN is only a gate on your device — your passwords '
                  'stay encrypted exactly as before.',
                ),
                if (widget.biometricsAvailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Biometrics are available: the OS will offer them at '
                      'the gate as the primary option.',
                    ),
                  ),
                const SizedBox(height: 24),
                TextField(
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (v) => _goNext(v, isConfirm: false),
                  decoration:
                      const InputDecoration(labelText: 'Create PIN'),
                ),
                const SizedBox(height: 12),
                TextField(
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (v) => _goNext(v, isConfirm: true),
                  decoration:
                      const InputDecoration(labelText: 'Confirm PIN'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enable quick unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
