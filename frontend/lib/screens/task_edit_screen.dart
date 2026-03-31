import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'dart:convert';

class TaskEditScreen extends StatefulWidget {
  final Task? task;
  const TaskEditScreen({super.key, this.task});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  
  String _status = 'To-Do';
  int? _blockedById;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _dateController = TextEditingController();
    _timeController = TextEditingController();

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _dateController.text = widget.task!.dueDate;
      _timeController.text = widget.task!.dueTime;
      _status = widget.task!.status;
      _blockedById = widget.task!.blockedById;
    } else {
      _loadDraft();
    }
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = prefs.getString('task_draft');
    if (draftJson != null) {
      final draft = json.decode(draftJson);
      setState(() {
        _titleController.text = draft['title'] ?? '';
        _descController.text = draft['description'] ?? '';
        _dateController.text = draft['dueDate'] ?? '';
        _timeController.text = draft['dueTime'] ?? '';
        _status = draft['status'] ?? 'To-Do';
        _blockedById = draft['blockedById'];
      });
    }
  }

  Future<void> _saveDraft() async {
    if (widget.task != null || _isSaving) return; // Edit mode or already saving prevents drafting.
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'title': _titleController.text,
      'description': _descController.text,
      'dueDate': _dateController.text,
      'dueTime': _timeController.text,
      'status': _status,
      'blockedById': _blockedById,
    };
    await prefs.setString('task_draft', json.encode(draft));
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('task_draft');
  }

  @override
  void dispose() {
    _saveDraft();
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final newTask = Task(
      id: widget.task?.id,
      title: _titleController.text,
      description: _descController.text,
      dueDate: _dateController.text,
      dueTime: _timeController.text,
      status: _status,
      blockedById: _blockedById,
    );

    try {
      if (widget.task == null) {
        await taskProvider.addTask(newTask);
        await _clearDraft();
      } else {
        await taskProvider.updateTask(widget.task!.id!, newTask);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final otherTasks = tasks.where((t) => t.id != widget.task?.id).toList();

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        _saveDraft();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Requires a title' : null,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                  validator: (val) => val == null || val.isEmpty ? 'Requires a description' : null,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(labelText: 'Due Date', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                  readOnly: true,
                  onTap: _isSaving ? null : () => _selectDate(context),
                  validator: (val) => val == null || val.isEmpty ? 'Requires a date' : null,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'Due Time', border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time)),
                  readOnly: true,
                  onTap: _isSaving ? null : () => _selectTime(context),
                  validator: (val) => val == null || val.isEmpty ? 'Requires a time' : null,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: ['To-Do', 'In Progress', 'Done'].map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                  onChanged: _isSaving ? null : (val) {
                    setState(() { _status = val!; });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  value: _blockedById,
                  decoration: const InputDecoration(labelText: 'Blocked By (Optional)', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('None')),
                    ...otherTasks.map((t) => DropdownMenuItem<int?>(value: t.id, child: Text(t.title))),
                  ],
                  onChanged: _isSaving ? null : (val) {
                    setState(() { _blockedById = val; });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSaving ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Text('Save Task', style: TextStyle(fontSize: 18)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
