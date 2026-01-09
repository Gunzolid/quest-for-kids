import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Future<void> Function(
    String title,
    String description,
    int points,
    bool isRecurring,
    DateTime? startTime,
    DateTime? endTime,
    String? imageUrl,
    int? reminderMinutes,
  )
  onSave;

  final String? initialTitle;
  final String? initialDescription;
  final int? initialPoints;
  final bool? initialIsRecurring;
  final DateTime? initialStartTime;
  final DateTime? initialEndTime;
  final String? initialImageUrl;
  final int? initialReminderMinutes;
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
    this.initialImageUrl,
    this.initialReminderMinutes,
    this.isEditing = false,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _imageUrlController;
  late int _points;
  late bool _isRecurring;
  bool _isLoading = false;
  DateTime? _startTime;
  DateTime? _endTime;
  int? _reminderMinutes;

  late TabController _tabController;

  final List<Map<String, dynamic>> _templates = [
    {'title': 'Clean Room', 'points': 20, 'icon': Icons.cleaning_services},
    {'title': 'Wash Dishes', 'points': 15, 'icon': Icons.local_dining},
    {'title': 'Read Book', 'points': 10, 'icon': Icons.book},
    {'title': 'Do Homework', 'points': 25, 'icon': Icons.school},
    {'title': 'Water Plants', 'points': 5, 'icon': Icons.local_florist},
    {'title': 'Walk Dog', 'points': 15, 'icon': Icons.pets},
    {'title': 'Take Trash Out', 'points': 5, 'icon': Icons.delete_outline},
    {'title': 'Exercise', 'points': 20, 'icon': Icons.fitness_center},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.initialImageUrl ?? '',
    );
    _points = widget.initialPoints ?? 10;
    _isRecurring = widget.initialIsRecurring ?? false;
    _startTime = widget.initialStartTime;
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
    _reminderMinutes = widget.initialReminderMinutes;

    _tabController = TabController(length: 2, vsync: this);
    if (widget.isEditing) {
      _tabController.index = 1; // Default to Custom if editing
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _useTemplate(Map<String, dynamic> template) {
    setState(() {
      _titleController.text = template['title'];
      _points = template['points'];
      _descController.text = 'Complete: ${template['title']}';
      _tabController.animateTo(1); // Switch to Custom tab
    });
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
          _imageUrlController.text.trim().isEmpty
              ? null
              : _imageUrlController.text.trim(),
          _reminderMinutes,
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
      title: Text(widget.isEditing ? 'Edit Mission' : 'Add New Mission'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.isEditing)
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Templates'),
                  Tab(text: 'Custom'),
                ],
              ),
            if (!widget.isEditing) const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent swipe for complex form
                children: [
                  // Tab 1: Templates
                  _buildTemplatesTab(),
                  // Tab 2: Custom Form
                  _buildCustomTab(),
                ],
              ),
            ),
          ],
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
              : Text(widget.isEditing ? 'Save Changes' : 'Assign Mission'),
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final t = _templates[index];
        return InkWell(
          onTap: () => _useTemplate(t),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(t['icon'], size: 32, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  t['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${t['points']} KP',
                  style: TextStyle(color: Colors.blue.shade800),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTab() {
    return Form(
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
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (Optional)',
                hintText: 'https://example.com/image.png',
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (_) => setState(() {}), // Trigger rebuild for preview
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
              title: Text(
                _startTime == null
                    ? 'Start Time (Optional)'
                    : 'Start: ${_formatDateTime(_startTime!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDateTime(true),
            ),
            ListTile(
              title: Text(
                _endTime == null
                    ? 'End Time (Optional)'
                    : 'End: ${_formatDateTime(_endTime!)}',
              ),
              trailing: const Icon(Icons.event_busy),
              onTap: () => _pickDateTime(false),
            ),
            if (_endTime != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.alarm, size: 20, color: Colors.grey),
                    const SizedBox(width: 16),
                    const Text('Remind me before: '),
                    const Spacer(),
                    DropdownButton<int?>(
                      value: _reminderMinutes,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('None')),
                        DropdownMenuItem(value: 15, child: Text('15 mins')),
                        DropdownMenuItem(value: 30, child: Text('30 mins')),
                        DropdownMenuItem(value: 60, child: Text('1 hour')),
                      ],
                      onChanged: (v) => setState(() => _reminderMinutes = v),
                      underline: Container(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
