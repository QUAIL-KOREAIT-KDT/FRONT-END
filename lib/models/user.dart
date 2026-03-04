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
