import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/app_constants.dart';
import '../../dependencies.dart';
import '../../models/project.dart';

class AddProjectScreen extends StatefulWidget {
  final String clientId;
  final Project? project;
  const AddProjectScreen({super.key, required this.clientId, this.project});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _budget;
  late final TextEditingController _url;
  late String _status;
  late String _selectedCurrency;
  bool _loading = false;

  bool get isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.project?.name ?? '');
    _desc = TextEditingController(text: widget.project?.description ?? '');
    _budget = TextEditingController(
      text: widget.project?.budget.toString() ?? '',
    );
    _url = TextEditingController(text: widget.project?.url ?? '');
    _status = widget.project?.status ?? 'To Do';
    _selectedCurrency = widget.project?.currency ?? 'EUR';
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _budget.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      if (isEditing) {
        await clientService.updateProject(
          projectId: widget.project!.id,
          name: _name.text.trim(),
          description: _desc.text.trim(),
          budget: double.tryParse(_budget.text) ?? 0.0,
          currency: _selectedCurrency,
          url: _url.text.trim().isEmpty ? null : _url.text.trim(),
          status: _status,
        );
      } else {
        await clientService.addProject(
          clientId: widget.clientId,
          name: _name.text.trim(),
          description: _desc.text.trim(),
          budget: double.tryParse(_budget.text) ?? 0.0,
          currency: _selectedCurrency,
          url: _url.text.trim().isEmpty ? null : _url.text.trim(),
          status: _status,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Project' : 'New Project')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              style: TextStyle(color: AppColors.textMain), // Fixed dark mode
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Project name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _budget,
                    style: TextStyle(
                      color: AppColors.textMain,
                    ), // Fixed dark mode
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Budget',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Budget is required';
                      }
                      if (double.tryParse(v) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCurrency,
                    style: TextStyle(
                      color: AppColors.textMain,
                    ), // Fixed dark mode
                    dropdownColor:
                        AppColors.surface, // Fixed dark mode dropdown
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.currencies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.code,
                            child: Text(c.code),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCurrency = v ?? 'EUR'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              style: TextStyle(color: AppColors.textMain), // Fixed dark mode
              dropdownColor: AppColors.surface, // Fixed dark mode dropdown
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.projectStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? 'To Do'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desc,
              style: TextStyle(color: AppColors.textMain), // Fixed dark mode
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _url,
              style: TextStyle(color: AppColors.textMain), // Fixed dark mode
              decoration: const InputDecoration(
                labelText: 'URL (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'Update Project' : 'Save Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
