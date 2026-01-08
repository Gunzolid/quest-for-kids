import 'package:flutter/material.dart';

class AddRewardDialog extends StatefulWidget {
  final Future<void> Function(String name, int cost, String? imageUrl) onSave;
  final String? initialName;
  final int? initialCost;
  final String? initialImageUrl;
  final bool isEditing;

  const AddRewardDialog({
    super.key,
    required this.onSave,
    this.initialName,
    this.initialCost,
    this.initialImageUrl,
    this.isEditing = false,
  });

  @override
  State<AddRewardDialog> createState() => _AddRewardDialogState();
}

class _AddRewardDialogState extends State<AddRewardDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _imageUrlController;
  late int _cost;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _imageUrlController = TextEditingController(
      text: widget.initialImageUrl ?? '',
    );
    _cost = widget.initialCost ?? 50;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await widget.onSave(
          _nameController.text.trim(),
          _cost,
          _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Reward' : 'Add New Reward'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Reward Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'https://example.com/reward.png',
                  prefixIcon: Icon(Icons.link),
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Image.network(
                      _imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('Invalid Image URL')),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Cost: '),
                  Expanded(
                    child: Slider(
                      value: _cost.toDouble(),
                      min: 10,
                      max: 1000,
                      divisions: 99,
                      label: _cost.toString(),
                      onChanged: (v) => setState(() => _cost = v.toInt()),
                    ),
                  ),
                  Text('$_cost KP'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : Text(widget.isEditing ? 'Save Changes' : 'Add Reward'),
        ),
      ],
    );
  }
}
