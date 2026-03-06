class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool read;
  final String timeAgo;
  final String avatarText;
  final String? avatarColor;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.timeAgo,
    required this.avatarText,
    this.avatarColor,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      read: json['read'] ?? false,
      timeAgo: _formatTime(json['createdAt']),
      avatarText: json['avatarText'] ?? (json['title'] as String? ?? 'N').substring(0, 1).toUpperCase(),
      avatarColor: json['avatarColor'],
    );
  }


  static String _formatTime(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    } catch (e) {
      return '';
    }
  }


  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      read: read ?? this.read,
      timeAgo: timeAgo,
      avatarText: avatarText,
      avatarColor: avatarColor,
    );
  }
}