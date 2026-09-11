/// Action Button inside APK / Download Item
class DownloadActionModel {
  final String id;
  final String label;
  final String url;
  final String icon;

  DownloadActionModel({
    required this.id,
    required this.label,
    required this.url,
    this.icon = 'download',
  });

  factory DownloadActionModel.fromJson(Map<String, dynamic> json) {
    return DownloadActionModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Download',
      url: json['url']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'download',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'url': url,
      'icon': icon,
    };
  }
}

/// APK Downloads & Gaming Tools Catalog Model
class DownloadItemModel {
  final String id;
  final String title;
  final String category;
  final String youtubeId;
  final String videoThumbnail;
  final String videoDuration;
  final bool isPinned;
  final int order;
  final int createdAt;
  final List<DownloadActionModel> actionButtons;

  DownloadItemModel({
    required this.id,
    required this.title,
    this.category = 'Mobin APK',
    this.youtubeId = '',
    this.videoThumbnail = '',
    this.videoDuration = '',
    this.isPinned = false,
    this.order = 0,
    int? createdAt,
    required this.actionButtons,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  factory DownloadItemModel.fromJson(Map<String, dynamic> json) {
    var rawActions = json['actionButtons'] as List? ?? [];
    List<DownloadActionModel> actions = rawActions
        .map((a) => DownloadActionModel.fromJson(a as Map<String, dynamic>))
        .toList();

    int parsedCreatedAt = DateTime.now().millisecondsSinceEpoch;
    if (json['createdAt'] is int) {
      parsedCreatedAt = json['createdAt'] as int;
    } else if (json['timestamp'] is int) {
      parsedCreatedAt = json['timestamp'] as int;
    } else if (json['createdAt'] is String) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'])?.millisecondsSinceEpoch ?? parsedCreatedAt;
    }

    int parsedOrder = 0;
    if (json['order'] is int) {
      parsedOrder = json['order'] as int;
    } else if (json['order'] != null) {
      parsedOrder = int.tryParse(json['order'].toString()) ?? 0;
    }

    return DownloadItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Mobin APK',
      youtubeId: json['youtubeId']?.toString() ?? json['videoId']?.toString() ?? '',
      videoThumbnail: json['videoThumbnail']?.toString() ?? json['thumbnail']?.toString() ?? json['imageUrl']?.toString() ?? '',
      videoDuration: json['videoDuration']?.toString() ?? '',
      isPinned: json['isPinned'] == true,
      order: parsedOrder,
      createdAt: parsedCreatedAt,
      actionButtons: actions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'youtubeId': youtubeId,
      'videoThumbnail': videoThumbnail,
      'videoDuration': videoDuration,
      'isPinned': isPinned,
      'order': order,
      'createdAt': createdAt,
      'actionButtons': actionButtons.map((a) => a.toJson()).toList(),
    };
  }
}
