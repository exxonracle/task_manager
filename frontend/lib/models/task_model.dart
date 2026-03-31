class Task {
  final int? id;
  final String title;
  final String description;
  final String dueDate;
  final String dueTime;
  final String status;
  final int? blockedById;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.status,
    this.blockedById,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['due_date'],
      dueTime: json['due_time'],
      status: json['status'],
      blockedById: json['blocked_by_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'due_time': dueTime,
      'status': status,
      'blocked_by_id': blockedById,
    };
  }
}
