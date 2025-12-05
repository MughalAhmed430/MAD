class UserModel {
  String uid;
  String email;
  String name;
  String? profileImage;
  List<String> favoriteEvents;
  List<String> registeredEvents;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profileImage,
    this.favoriteEvents = const [],
    this.registeredEvents = const [],
  });

  // Add this copyWith method
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? profileImage,
    List<String>? favoriteEvents,
    List<String>? registeredEvents,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      favoriteEvents: favoriteEvents ?? this.favoriteEvents,
      registeredEvents: registeredEvents ?? this.registeredEvents,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'favoriteEvents': favoriteEvents,
      'registeredEvents': registeredEvents,
      'createdAt': DateTime.now(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImage: map['profileImage'],
      favoriteEvents: List<String>.from(map['favoriteEvents'] ?? []),
      registeredEvents: List<String>.from(map['registeredEvents'] ?? []),
    );
  }

  // Get initials for avatar
  String get initials {
    if (name.isEmpty) return 'U';
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}