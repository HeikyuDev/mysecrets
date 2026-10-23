import 'package:flutter/material.dart';

class UnlockScreen extends StatefulWidget {
  final Future<bool> Function(String masterPassphrase) onUnlock;

  const UnlockScreen({super.key, required this.onUnlock});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  bool _failed = false;

  Future<void> _submit() async {
    if (_pass.text.isEmpty) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    final ok = await widget.onUnlock(_pass.text);
    if (!mounted) return;
    if (ok) return;
    setState(() {
      _busy = false;
      _failed = true;
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
                  controller: _pass,
                  obscureText: _obscure,
                  autofocus: true,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Master passphrase',
                    errorText: _failed ? 'Wrong passphrase' : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
