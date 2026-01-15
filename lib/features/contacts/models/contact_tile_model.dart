class ContactTileModel {
  final String nickname;
  final String? realName;
  final String phoneNumber;
  final String? photoPath;

  ContactTileModel({
    required this.nickname,
    this.realName,
    required this.phoneNumber,
    this.photoPath,
  });

  // JSON serialization for persistent storage
  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'realName': realName,
      'phoneNumber': phoneNumber,
      'photoPath': photoPath,
    };
  }

  factory ContactTileModel.fromJson(Map<String, dynamic> json) {
    return ContactTileModel(
      nickname: json['nickname'] as String,
      realName: json['realName'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      photoPath: json['photoPath'] as String?,
    );
  }

  // Create a copy with updated fields
  ContactTileModel copyWith({
    String? nickname,
    String? realName,
    String? phoneNumber,
    String? photoPath,
  }) {
    return ContactTileModel(
      nickname: nickname ?? this.nickname,
      realName: realName ?? this.realName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
