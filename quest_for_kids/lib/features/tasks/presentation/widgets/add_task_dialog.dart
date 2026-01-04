import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Future<void> Function(String title, String description, int points,
      bool isRecurring, DateTime? startTime, DateTime? endTime) onSave;

  final String? initialTitle;
  final String? initialDescription;
  final int? initialPoints;
  final bool? initialIsRecurring;
  final DateTime? initialStartTime;
  final DateTime? initialEndTime;
  final bool isEditing;

  const AddTaskDialog({
    super.key,
    required this.onSave,
    this.initialTitle,
    this.initialDescription,
    this.initialPoints,
    this.initialIsRecurring,
    this.initialStartTime,
    this.initialEndTime,
    this.isEditing = false,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late int _points;
  late bool _isRecurring;
  bool _isLoading = false;
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descController =
        TextEditingController(text: widget.initialDescription ?? '');
    _points = widget.initialPoints ?? 10;
    _isRecurring = widget.initialIsRecurring ?? false;
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = dateTime;
        // Reset end time if it's before new start time
        if (_endTime != null && _endTime!.isBefore(_startTime!)) {
          _endTime = null;
        }
      } else {
        _endTime = dateTime;
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_endTime != null &&
          _startTime != null &&
          _endTime!.isBefore(_startTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time cannot be before start time')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        await widget.onSave(
          _titleController.text.trim(),
          _descController.text.trim(),
          _points,
          _isRecurring,
          _startTime,
          _endTime,
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Mission' : 'Add New Mission'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Mission Title'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Points: '),
                  Expanded(
                    child: Slider(
                      value: _points.toDouble(),
                      min: 5,
                      max: 100,
                      divisions: 19,
                      label: _points.toString(),
                      onChanged: (v) => setState(() => _points = v.toInt()),
                    ),
                  ),
                  Text('$_points KP'),
                ],
              ),
              SwitchListTile(
                title: const Text('Daily Recurring?'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
              ),
              const Divider(),
              ListTile(
                title: Text(_startTime == null
                    ? 'Start Time (Optional)'
                    : 'Start: ${_formatDateTime(_startTime!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(true),
              ),
              ListTile(
                title: Text(_endTime == null
                    ? 'End Time (Optional)'
                    : 'End: ${_formatDateTime(_endTime!)}'),
                trailing: const Icon(Icons.event_busy),
                onTap: () => _pickDateTime(false),
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
                  width: 20, height: 20, child: CircularProgressIndicator())
              : Text(widget.isEditing ? 'Save Changes' : 'Assign Mission'),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
