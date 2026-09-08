class DiamondPackageModel {
  final String id;
  final String name;
  final int diamonds;
  final double priceBDT;
  final String? bonus;
  final String iconPath;

  const DiamondPackageModel({
    required this.id,
    required this.name,
    required this.diamonds,
    required this.priceBDT,
    this.bonus,
    required this.iconPath,
  });

  factory DiamondPackageModel.fromMap(Map<String, dynamic> map, String docId) {
    return DiamondPackageModel(
      id: docId,
      name: map['name'] ?? '',
      diamonds: map['diamonds']?.toInt() ?? 0,
      priceBDT: map['priceBDT']?.toDouble() ?? 0.0,
      bonus: map['bonus'],
      iconPath: map['iconPath'] ?? '',
    );
  }
}
