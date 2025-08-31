import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles your app supports
enum UserRole { admin, sheikh, parent }

UserRole _roleFromString(String s) =>
    UserRole.values.firstWhere((e) => e.name == s, orElse: () => UserRole.parent);

/// Simple user model
class AppUser {
  final String id;
  final String username; // unique, lowercase
  final String name;
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
    required this.name,

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
      name: d['name'] as String,
      username: (d['username'] as String?)?.toLowerCase().trim() ?? '',
      role: _roleFromString(d['role'] as String),
      email: d['email'] as String?,
      phone: d['phone'] as String?,
      status: d['status'] as String? ?? 'active',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (d['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({String? passwordHash}) {
    return {
      'id': id,
      'username': username,
      if (passwordHash != null) 'password': passwordHash,
      'role': role.name,
      'email': email,
      'phone': phone,
      'status': status,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  /// Convert to map for JSON serialization (SharedPreferences)
  Map<String, dynamic> toJsonMap() {
    return {
      'id': id,
      'username': username,
      'role': role.name,
      'email': email,
      'phone': phone,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory AppUser.fromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppUser(
        id: data['id'] as String,
        name: data['name'] as String,
        username: data['username'] as String,
        role: _roleFromString(data['role'] as String),
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        status: data['status'] as String? ?? 'active',
        createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt'] as String) : null,
        lastLogin: data['lastLogin'] != null ? DateTime.parse(data['lastLogin'] as String) : null,
      );
    } catch (e) {
      throw FormatException('Failed to parse AppUser from JSON: $e');
    }
  }

  copyWith({
    String? id,
    String? name,
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
      name: name ?? this.name,
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
