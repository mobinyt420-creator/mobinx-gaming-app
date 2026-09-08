/// Mobin X Verified Player & Admin Profile Model
class UserModel {
  final String id;
  final String uid;
  final int userId;
  final int playerNumber;
  final String name;
  final String username;
  final String fullName;
  final String email;
  final bool emailVerified;
  final String phone;
  final bool phoneVerified;
  final String ffUid;
  final String avatar;
  final String authProvider;
  final String role;
  final bool isAdmin;
  final String status;
  final int walletBalance;
  final int tournamentsJoined;
  final int totalDownloads;
  final int savedSensitivities;
  final String referralCode;
  final double referralEarnings;
  final int referralCount;
  final String registeredDate;
  final String lastLoginAt;

  UserModel({
    required this.id,
    required this.uid,
    this.userId = 1,
    this.playerNumber = 1,
    required this.name,
    required this.username,
    required this.fullName,
    required this.email,
    this.emailVerified = false,
    this.phone = '',
    this.phoneVerified = false,
    this.ffUid = '',
    this.avatar = 'assets/images/avatar_user.jpg',
    this.authProvider = 'google',
    this.role = 'VIP Pro Member',
    this.isAdmin = false,
    this.status = 'Active',
    this.walletBalance = 0,
    this.tournamentsJoined = 0,
    this.totalDownloads = 0,
    this.savedSensitivities = 0,
    this.referralCode = 'MOBINXVIP',
    this.referralEarnings = 0.0,
    this.referralCount = 0,
    this.registeredDate = 'Just now',
    this.lastLoginAt = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['uid']?.toString() ?? '',
      uid: json['uid']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '1') ?? 1,
      playerNumber: json['playerNumber'] is int ? json['playerNumber'] : int.tryParse(json['playerNumber']?.toString() ?? '1') ?? 1,
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'Player',
      username: json['username']?.toString() ?? 'Player',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? 'Player',
      email: json['email']?.toString() ?? '',
      emailVerified: json['emailVerified'] == true,
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      phoneVerified: json['phoneVerified'] == true,
      ffUid: json['ffUid']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? 'assets/images/avatar_user.jpg',
      authProvider: json['authProvider']?.toString() ?? 'google',
      role: json['role']?.toString() ?? 'VIP Pro Member',
      isAdmin: json['isAdmin'] == true,
      status: json['status']?.toString() ?? 'Active',
      walletBalance: json['walletBalance'] is int ? json['walletBalance'] : int.tryParse(json['walletBalance']?.toString() ?? '0') ?? 0,
      tournamentsJoined: json['stats']?['tournamentsJoined'] is int ? json['stats']['tournamentsJoined'] : 0,
      totalDownloads: json['stats']?['totalDownloads'] is int ? json['stats']['totalDownloads'] : 0,
      savedSensitivities: json['stats']?['savedSensitivities'] is int ? json['stats']['savedSensitivities'] : 0,
      referralCode: json['referralCode']?.toString() ?? 'MOBINXVIP',
      referralEarnings: (json['referralEarnings'] is num ? json['referralEarnings'].toDouble() : double.tryParse(json['referralEarnings']?.toString() ?? '0.0')) ?? 0.0,
      referralCount: json['stats']?['referralsCount'] is int ? json['stats']['referralsCount'] : (json['referralCount'] is int ? json['referralCount'] : 0),
      registeredDate: json['registeredDate']?.toString() ?? 'Just now',
      lastLoginAt: json['lastLoginAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'userId': userId,
      'playerNumber': playerNumber,
      'name': name,
      'username': username,
      'fullName': fullName,
      'email': email,
      'emailVerified': emailVerified,
      'phone': phone,
      'phoneNumber': phone,
      'phoneVerified': phoneVerified,
      'ffUid': ffUid,
      'avatar': avatar,
      'authProvider': authProvider,
      'role': role,
      'isAdmin': isAdmin,
      'status': status,
      'walletBalance': walletBalance,
      'stats': {
        'tournamentsJoined': tournamentsJoined,
        'totalDownloads': totalDownloads,
        'savedSensitivities': savedSensitivities,
      },
      'registeredDate': registeredDate,
      'lastLoginAt': lastLoginAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? username,
    String? phone,
    bool? phoneVerified,
    String? ffUid,
    String? avatar,
    int? walletBalance,
    int? tournamentsJoined,
    int? totalDownloads,
    int? savedSensitivities,
  }) {
    return UserModel(
      id: id,
      uid: uid,
      userId: userId,
      playerNumber: playerNumber,
      name: name ?? this.name,
      username: username ?? this.username,
      fullName: name ?? fullName,
      email: email,
      emailVerified: emailVerified,
      phone: phone ?? this.phone,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      ffUid: ffUid ?? this.ffUid,
      avatar: avatar ?? this.avatar,
      authProvider: authProvider,
      role: role,
      isAdmin: isAdmin,
      status: status,
      walletBalance: walletBalance ?? this.walletBalance,
      tournamentsJoined: tournamentsJoined ?? this.tournamentsJoined,
      totalDownloads: totalDownloads ?? this.totalDownloads,
      savedSensitivities: savedSensitivities ?? this.savedSensitivities,
      registeredDate: registeredDate,
      lastLoginAt: lastLoginAt,
    );
  }
}
