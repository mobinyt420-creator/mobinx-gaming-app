/// Free Fire Custom Room & Esports Tournament Model
class TournamentModel {
  final String id;
  final String title;
  final String mode; // Solo, Duo, Squad
  final String map; // Bermuda, Purgatory, Kalahari, Alpine
  final String entryFee; // Free, ৳ 50, etc.
  final String prizePool; // ৳ 500, 1000 Diamonds, etc.
  final int slotsTotal;
  final int slotsFilled;
  final String matchTime; // "Tonight at 08:30 PM"
  final String banner;
  final String status; // Upcoming, Ongoing, Completed
  final bool isLive;
  final String roomId;
  final String roomPass;
  final bool isRoomReleased;

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
    this.banner = 'assets/images/banner_esports.jpg',
    this.status = 'Upcoming',
    this.isLive = false,
    this.roomId = '',
    this.roomPass = '',
    this.isRoomReleased = false,
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
      matchTime: json['matchTime']?.toString() ?? 'Tonight at 08:30 PM',
      banner: json['banner']?.toString() ?? json['bannerUrl']?.toString() ?? 'assets/images/banner_esports.jpg',
      status: json['status']?.toString() ?? 'Upcoming',
      isLive: json['isLive'] == true,
      roomId: roomCreds?['roomId']?.toString() ?? json['roomId']?.toString() ?? '',
      roomPass: roomCreds?['password']?.toString() ?? json['roomPass']?.toString() ?? '',
      isRoomReleased: roomCreds?['isReleased'] == true || json['isRoomReleased'] == true,
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
      'banner': banner,
      'status': status,
      'isLive': isLive,
      'roomId': roomId,
      'roomPass': roomPass,
      'isRoomReleased': isRoomReleased,
    };
  }
}
