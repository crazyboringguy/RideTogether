class Trip {
  const Trip({
    required this.id,
    required this.hostUserId,
    required this.name,
    required this.source,
    required this.destination,
    required this.joinCode,
    required this.createdAt,
    required this.updatedAt,
    this.role,
  });

  final String id;
  final String hostUserId;
  final String name;
  final String source;
  final String destination;
  final String joinCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? role;

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        hostUserId: json['hostUserId'] as String,
        name: json['name'] as String,
        source: json['source'] as String,
        destination: json['destination'] as String,
        joinCode: json['joinCode'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        role: json['role'] as String?,
      );
}

class TripMember {
  const TripMember({required this.id, required this.name, required this.email, required this.role, required this.joinedAt});

  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime joinedAt;

  factory TripMember.fromJson(Map<String, dynamic> json) => TripMember(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );
}
