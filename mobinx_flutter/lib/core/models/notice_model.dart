/// Mobin X In-App Notice & Dynamic Announcement Model
class NoticeModel {
  final String id;
  final String title;
  final String message;
  final String category;
  final String? imageUrl;
  final String? actionUrl;
  final String actionText;
  final bool isActive;
  final DateTime? timestamp;

  NoticeModel({
    required this.id,
    required this.title,
    required this.message,
    this.category = 'ANNOUNCEMENT',
    this.imageUrl,
    this.actionUrl,
    this.actionText = 'GOT IT',
    this.isActive = true,
    this.timestamp,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id']?.toString() ?? json['broadcastId']?.toString() ?? 'notice_default',
      title: json['title']?.toString() ?? 'Official Announcement',
      message: json['message']?.toString() ?? json['desc']?.toString() ?? '',
      category: json['type']?.toString().toUpperCase() ?? json['category']?.toString().toUpperCase() ?? 'ANNOUNCEMENT',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      actionUrl: json['actionUrl']?.toString() ?? json['targetUrl']?.toString(),
      actionText: json['actionText']?.toString() ?? 'OK, GOT IT',
      isActive: json['active'] != false && json['isActive'] != false,
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
              : null)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'isActive': isActive,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }
}
