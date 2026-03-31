import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'task_edit_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  final List<String> _statuses = ['All', 'To-Do', 'In Progress', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _statusFilter,
              onChanged: (String? newValue) {
                setState(() {
                  _statusFilter = newValue!;
                });
              },
              items: _statuses.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: const SizedBox(),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.error != null) {
                  return Center(child: Text('Error: ${provider.error}'));
                }

                List<Task> filteredTasks = provider.tasks.where((task) {
                  final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesStatus = _statusFilter == 'All' || task.status == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filteredTasks.isEmpty) {
                  return const Center(child: Text('No tasks found. Create one.'));
                }

                return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    
                    bool isBlocked = false;
                    if (task.blockedById != null) {
                      final blocker = provider.tasks.firstWhere(
                        (t) => t.id == task.blockedById,
                        orElse: () => Task(title: '', description: '', dueDate: '', dueTime: '', status: 'Done'),
                      );
                      if (blocker.status != 'Done' && blocker.id != null) {
                        isBlocked = true;
                      }
                    }

                    return Opacity(
                      opacity: isBlocked ? 0.5 : 1.0,
                      child: Card(
                        color: isBlocked ? Theme.of(context).disabledColor.withOpacity(0.1) : null,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(task.title, style: TextStyle(
                            decoration: task.status == 'Done' ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: task.status == 'Done' ? Colors.green.shade100 
                                           : task.status == 'In Progress' ? Colors.orange.shade100
                                           : Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      task.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: task.status == 'Done' ? Colors.green.shade800
                                             : task.status == 'In Progress' ? Colors.orange.shade800
                                             : Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Due: ${task.dueDate} at ${task.dueTime}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                ],
                              ),
                              if (isBlocked) 
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lock_clock, size: 14, color: Colors.redAccent),
                                      const SizedBox(width: 4),
                                      Text('Blocked by another task', style: TextStyle(color: Colors.red.shade400, fontSize: 12, fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          isThreeLine: isBlocked,
                          onTap: isBlocked ? null : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskEditScreen(task: task),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              if (task.id != null) {
                                provider.deleteTask(task.id!);
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
