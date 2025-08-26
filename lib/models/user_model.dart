import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles your app supports
enum UserRole { admin, sheikh, parent }

UserRole _roleFromString(String s) =>
    UserRole.values.firstWhere((e) => e.name == s, orElse: () => UserRole.parent);

/// Simple user model
class AppUser {
  final String id;
  final String username; // unique, lowercase
  final UserRole role;
  final String? email;
  final String? phone;
  final String status; // active | inactive | blocked
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.id,
    required this.username,
    required this.role,

    this.email,
    this.phone,
    required this.status,
    this.createdAt,
    this.lastLogin,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AppUser(
      id: doc.id,
      username: (d['username'] as String?)?.toLowerCase().trim() ?? '',
      role: _roleFromString(d['role'] as String),
      email: d['email'] as String?,
      phone: d['phone'] as String?,
      status: d['status'] as String? ?? 'active',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (d['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({required String passwordHash}) => {
        'username': username,
        'password': passwordHash,
        'role': role.name,   
        'email': email,
        'phone': phone,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };

  copyWith({
    String? id,
    String? username,
    UserRole? role,
    String? email,
    String? phone,
    String? status,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
