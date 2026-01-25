class UserModel {
  final String? id;
  final String? email;
  final String? nickname;
  final String? profileImage;
  final String? location;
  final double? indoorTemperature;
  final String? houseDirection;
  final bool isOnboardingCompleted;

  UserModel({
    this.id,
    this.email,
    this.nickname,
    this.profileImage,
    this.location,
    this.indoorTemperature,
    this.houseDirection,
    this.isOnboardingCompleted = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      profileImage: json['profile_image'],
      location: json['location'],
      indoorTemperature: json['indoor_temperature']?.toDouble(),
      houseDirection: json['house_direction'],
      isOnboardingCompleted: json['is_onboarding_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'profile_image': profileImage,
      'location': location,
      'indoor_temperature': indoorTemperature,
      'house_direction': houseDirection,
      'is_onboarding_completed': isOnboardingCompleted,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nickname,
    String? profileImage,
    String? location,
    double? indoorTemperature,
    String? houseDirection,
    bool? isOnboardingCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      indoorTemperature: indoorTemperature ?? this.indoorTemperature,
      houseDirection: houseDirection ?? this.houseDirection,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }
}
