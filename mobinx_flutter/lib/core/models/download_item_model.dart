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
  final List<DownloadActionModel> actionButtons;

  DownloadItemModel({
    required this.id,
    required this.title,
    this.category = 'Mobin APK',
    this.youtubeId = '',
    this.videoThumbnail = 'assets/images/banner_yt_mock1.jpg',
    this.videoDuration = '08:45',
    this.isPinned = false,
    required this.actionButtons,
  });

  factory DownloadItemModel.fromJson(Map<String, dynamic> json) {
    var rawActions = json['actionButtons'] as List? ?? [];
    List<DownloadActionModel> actions = rawActions
        .map((a) => DownloadActionModel.fromJson(a as Map<String, dynamic>))
        .toList();

    return DownloadItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Mobin APK',
      youtubeId: json['youtubeId']?.toString() ?? '',
      videoThumbnail: json['videoThumbnail']?.toString() ?? 'assets/images/banner_yt_mock1.jpg',
      videoDuration: json['videoDuration']?.toString() ?? '08:45',
      isPinned: json['isPinned'] == true,
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
      'actionButtons': actionButtons.map((a) => a.toJson()).toList(),
    };
  }
}
