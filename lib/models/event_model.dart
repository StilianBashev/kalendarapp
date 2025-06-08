class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String createdBy;
  final DateTime createdAt;
  final String? color;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.createdAt,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      if (color != null) 'color': color,
    };
  }

  factory EventModel.fromMap(String id, Map<String, dynamic> map) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.tryParse(map['startTime'].replaceFirst('Z', '')) ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime'].replaceFirst('Z', '')) ?? DateTime.now(),
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'].replaceFirst('Z', '')) ?? DateTime.now(),
      color: map['color'],
    );
  }
}