import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  final Future<void> Function(String masterPassphrase) onSetup;

  const SetupScreen({super.key, required this.onSetup});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _acceptedDataLoss = false;
  bool _busy = false;

  double get _strength {
    final p = _pass.text;
    var score = 0;
    if (p.length >= 12) score++;
    if (p.length >= 20) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return score / 5;
  }

  String? _passValidator(String? value) {
    if (value == null || value.length < 12) {
      return 'Use at least 12 characters';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pass.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passphrases do not match')),
      );
      return;
    }
    if (!_acceptedDataLoss) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Confirm you understand: the master passphrase cannot be recovered')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.onSetup(_pass.text);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create your master passphrase',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This single passphrase protects everything. '
                    'mySecrets cannot recover it — there is no reset.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _pass,
                    obscureText: _obscure,
                    validator: _passValidator,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Master passphrase',
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _strength),
                  const SizedBox(height: 4),
                  Text(
                    _strength < 0.6
                        ? 'Weak — mix lengths, cases and symbols'
                        : 'Strong enough',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    validator: _passValidator,
                    decoration: const InputDecoration(
                      labelText: 'Confirm passphrase',
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _acceptedDataLoss,
                    onChanged: (v) => setState(() => _acceptedDataLoss = v!),
                    title: const Text(
                      'I understand: if I forget this passphrase, my data is '
                      'gone — there is NO recovery.',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Create my vault'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
