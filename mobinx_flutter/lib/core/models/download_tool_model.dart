class DownloadToolModel {
  final String id;
  final String name;
  final String description;
  final String version;
  final String size;
  final String downloadUrl;
  final String icon;
  final bool isPremium;

  const DownloadToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.size,
    required this.downloadUrl,
    required this.icon,
    this.isPremium = false,
  });
}
