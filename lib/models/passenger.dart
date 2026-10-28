class Passenger {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;

  Passenger({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      isVerified: json['is_verified'],
    );
  }
}