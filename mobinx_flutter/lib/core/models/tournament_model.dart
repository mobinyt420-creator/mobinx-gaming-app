/// Free Fire Custom Room & Esports Tournament Model
class TournamentModel {
  final String id;
  final String title;
  final String mode; // Solo, Duo, Squad, 4v4 Clash Squad
  final String map; // Bermuda, Purgatory, Kalahari, Alpine
  final String entryFee; // Free, ৳ 50, 50 Diamonds, etc.
  final String prizePool; // ৳ 50,000, 1000 Diamonds, etc.
  final int slotsTotal;
  final int slotsFilled;
  final String matchTime; // "Tonight at 08:30 PM"
  final String date; // "TODAY", "TOMORROW"
  final String banner;
  final String status; // Upcoming, Ongoing, Completed
  final bool isLive;
  final String roomId;
  final String roomPass;
  final bool isRoomReleased;
  final String rules;
  final bool isRegistered;

  String get roomPassword => roomPass;

  TournamentModel({
    required this.id,
    required this.title,
    required this.mode,
    this.map = 'Bermuda',
    required this.entryFee,
    required this.prizePool,
    this.slotsTotal = 48,
    this.slotsFilled = 0,
    required this.matchTime,
    this.date = 'TODAY',
    this.banner = 'assets/images/banner_esports.jpg',
    this.status = 'Upcoming',
    this.isLive = false,
    this.roomId = '',
    this.roomPass = '',
    this.isRoomReleased = false,
    this.rules = 'Fair play policy. Emotes allowed. No hacks or PC emulators in mobile rooms.',
    this.isRegistered = false,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    final roomCreds = json['roomCredentials'] is Map ? json['roomCredentials'] : null;
    return TournamentModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Free Fire Custom Match',
      mode: json['mode']?.toString() ?? json['gameMode']?.toString() ?? 'Squad',
      map: json['map']?.toString() ?? 'Bermuda',
      entryFee: json['entryFee']?.toString() ?? 'Free',
      prizePool: json['prizePool']?.toString() ?? '৳ 500',
      slotsTotal: json['slotsTotal'] is int ? json['slotsTotal'] : int.tryParse(json['slotsTotal']?.toString() ?? '48') ?? 48,
      slotsFilled: json['slotsFilled'] is int ? json['slotsFilled'] : int.tryParse(json['slotsFilled']?.toString() ?? '0') ?? 0,
      matchTime: json['matchTime']?.toString() ?? json['time']?.toString() ?? 'Tonight at 08:30 PM',
      date: json['date']?.toString() ?? 'TODAY',
      banner: json['banner']?.toString() ?? json['bannerUrl']?.toString() ?? 'assets/images/banner_esports.jpg',
      status: json['status']?.toString() ?? 'Upcoming',
      isLive: json['isLive'] == true || json['status']?.toString().toUpperCase() == 'ONGOING',
      roomId: roomCreds?['roomId']?.toString() ?? json['roomId']?.toString() ?? '',
      roomPass: roomCreds?['password']?.toString() ?? json['roomPass']?.toString() ?? '',
      isRoomReleased: roomCreds?['isReleased'] == true || json['isRoomReleased'] == true,
      rules: json['rules']?.toString() ?? 'Fair play policy. Emotes allowed. No hacks or PC emulators in mobile rooms.',
      isRegistered: json['isRegistered'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'mode': mode,
      'map': map,
      'entryFee': entryFee,
      'prizePool': prizePool,
      'slotsTotal': slotsTotal,
      'slotsFilled': slotsFilled,
      'matchTime': matchTime,
      'date': date,
      'banner': banner,
      'status': status,
      'isLive': isLive,
      'roomId': roomId,
      'roomPass': roomPass,
      'isRoomReleased': isRoomReleased,
      'rules': rules,
      'isRegistered': isRegistered,
    };
  }

  TournamentModel copyWith({
    String? id,
    String? title,
    String? mode,
    String? map,
    String? entryFee,
    String? prizePool,
    int? slotsTotal,
    int? slotsFilled,
    String? matchTime,
    String? date,
    String? banner,
    String? status,
    bool? isLive,
    String? roomId,
    String? roomPass,
    bool? isRoomReleased,
    String? rules,
    bool? isRegistered,
  }) {
    return TournamentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      mode: mode ?? this.mode,
      map: map ?? this.map,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      slotsTotal: slotsTotal ?? this.slotsTotal,
      slotsFilled: slotsFilled ?? this.slotsFilled,
      matchTime: matchTime ?? this.matchTime,
      date: date ?? this.date,
      banner: banner ?? this.banner,
      status: status ?? this.status,
      isLive: isLive ?? this.isLive,
      roomId: roomId ?? this.roomId,
      roomPass: roomPass ?? this.roomPass,
      isRoomReleased: isRoomReleased ?? this.isRoomReleased,
      rules: rules ?? this.rules,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
