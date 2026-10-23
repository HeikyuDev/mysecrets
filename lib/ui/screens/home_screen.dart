import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/vault_controller.dart';
import '../../vault/credential.dart';

class HomeScreen extends StatefulWidget {
  final VaultController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _addCredential() async {
    final saved = await showModalBottomSheet<Credential>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddCredentialSheet(controller: widget.controller),
    );
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${saved.platform}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final credentials = widget.controller.credentials;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.lock_outline),
                tooltip: 'Lock vault',
                onPressed: widget.controller.lock,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addCredential,
            child: const Icon(Icons.add),
          ),
          body: credentials.isEmpty
              ? const Center(
                  child: Text('No credentials yet.\nTap + to add your first one.',
                      textAlign: TextAlign.center),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: credentials.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = credentials[i];
                    return _CredentialCard(credential: c);
                  },
                ),
        );
      },
    );
  }
}

class _CredentialCard extends StatelessWidget {
  final Credential credential;

  const _CredentialCard({required this.credential});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(credential.platform),
        subtitle: Text(credential.username),
        trailing: const Icon(Icons.copy, size: 18),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: credential.password));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password copied')),
            );
          }
        },
      ),
    );
  }
}

class _AddCredentialSheet extends StatefulWidget {
  final VaultController controller;

  const _AddCredentialSheet({required this.controller});

  @override
  State<_AddCredentialSheet> createState() => _AddCredentialSheetState();
}

class _AddCredentialSheetState extends State<_AddCredentialSheet> {
  final _formKey = GlobalKey<FormState>();
  final _platform = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _notes = TextEditingController();
  int _rotationDays = 180;
  bool _busy = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    await widget.controller.addCredential(
      platform: _platform.text.trim(),
      username: _username.text.trim(),
      password: _password.text,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      rotationPolicyDays: _rotationDays,
    );
    if (mounted) Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('New credential',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _platform,
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: const InputDecoration(
                    labelText: 'Platform (e.g. GitHub)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _username,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: const InputDecoration(
                    labelText: 'Username or email'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _rotationDays,
                decoration: const InputDecoration(
                    labelText: 'Remind me to rotate every'),
                items: const [
                  DropdownMenuItem(value: 90, child: Text('90 days')),
                  DropdownMenuItem(value: 180, child: Text('180 days')),
                  DropdownMenuItem(value: 365, child: Text('365 days')),
                ],
                onChanged: (v) => setState(() => _rotationDays = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save credential'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
