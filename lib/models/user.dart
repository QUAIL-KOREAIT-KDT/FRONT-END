class UserModel {
  final String? id;
  final String? email;
  final String? nickname;
  final String? profileImage;
  final String? location;
  final double? indoorTemperature;
  final double? indoorHumidity;
  final String? houseDirection;
  final String? underground;
  final bool isOnboardingCompleted;

  UserModel({
    this.id,
    this.email,
    this.nickname,
    this.profileImage,
    this.location,
    this.indoorTemperature,
    this.indoorHumidity,
    this.houseDirection,
    this.underground,
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
      indoorHumidity: json['indoor_humidity']?.toDouble(),
      houseDirection: json['house_direction'],
      underground: json['underground'],
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
      'indoor_humidity': indoorHumidity,
      'house_direction': houseDirection,
      'underground': underground,
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
    double? indoorHumidity,
    String? houseDirection,
    String? underground,
    bool? isOnboardingCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      indoorTemperature: indoorTemperature ?? this.indoorTemperature,
      indoorHumidity: indoorHumidity ?? this.indoorHumidity,
      houseDirection: houseDirection ?? this.houseDirection,
      underground: underground ?? this.underground,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }
}
