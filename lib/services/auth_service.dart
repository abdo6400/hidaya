import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/firestore_constants.dart';

class AuthException implements Exception {
  final String code;
  final String message;
  AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException($code): $message';
}

class AuthService {
  AuthService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => 
      _db.collection(FirestoreCollections.users);
      
  DocumentReference<Map<String, dynamic>> _usernameIndexRef(String uname) =>
      _db.collection(FirestoreCollections.usernameIndex).doc(uname);

  /// Normalizes username: trim + lowercase
  String _normalize(String username) => username.trim().toLowerCase();

  /// Basic username policy (3–20 chars, allowed a-z 0-9 . _ -)
  void _assertValidUsername(String username) {
    final ok = RegExp(r'^[a-z0-9._-]{3,20}$').hasMatch(username);
    if (!ok) {
      throw AuthException('invalid_username', 'Username must be 3–20 chars and use: a-z 0-9 . _ -');
    }
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password against hash
  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  /// Registers a new user, enforcing unique username using a Firestore transaction.
  Future<AppUser> register({
    required String username,
    required String password,
    required UserRole role,
    required String name,
    String? email,
    String? phone,
    String? status = 'blocked',
  }) async {
    final uname = _normalize(username);
    _assertValidUsername(uname);
    if (password.trim().length < 6) {
      throw AuthException('weak_password', 'Password must be at least 6 chars.');
    }

    final userRef = _users.doc(); // pre-generate id
    final unameRef = _usernameIndexRef(uname);

    await _db.runTransaction((tx) async {
      final unameSnap = await tx.get(unameRef);
      if (unameSnap.exists) {
        throw AuthException('username_taken', 'Username is already in use.');
      }

      tx.set(userRef, {
        FirestoreFields.username: uname,
        FirestoreFields.password: _hashPassword(password),
        FirestoreFields.role: role.name,
        FirestoreFields.name: name,
        FirestoreFields.email: email,
        FirestoreFields.phone: phone,
        FirestoreFields.status: status,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      tx.set(unameRef, {'userId': userRef.id, 'createdAt': FieldValue.serverTimestamp()});
    });

    final created = await userRef.get();
    return AppUser.fromDoc(created);
  }

  /// Login with username + password.
  /// Looks up usernameIndex -> userId -> users doc, verifies bcrypt,
  /// updates lastLogin, returns user.
  Future<AppUser> login({required String username, required String password}) async {
    final uname = _normalize(username);
    _assertValidUsername(uname);

    final unameDoc = await _usernameIndexRef(uname).get();
    if (!unameDoc.exists) {
      throw AuthException('not_found', 'User not found.');
    }

    final userId = (unameDoc.data() ?? const {})['userId'] as String?;
    if (userId == null) {
      throw AuthException('corrupt_index', 'Account index is corrupted.');
    }

    final userDoc = await _users.doc(userId).get();
    if (!userDoc.exists) {
      throw AuthException('not_found', 'User not found.');
    }

    final data = userDoc.data()!;
    if ((data['status'] as String?) == 'blocked') {
      throw AuthException('blocked', 'Account is blocked.');
    }

    final storedHash = data['password'] as String?;
    if (storedHash == null || !_verifyPassword(password, storedHash)) {
      throw AuthException('wrong_password', 'Incorrect password.');
    }

    // Update lastLogin
    await userDoc.reference.update({'lastLogin': FieldValue.serverTimestamp()});

    return AppUser.fromDoc(await userDoc.reference.get());
  }

  /// Change password (verifies old password).
  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    if (newPassword.trim().length < 6) {
      throw AuthException('weak_password', 'Password must be at least 6 chars.');
    }

    final ref = _users.doc(userId);
    final snap = await ref.get();
    if (!snap.exists) throw AuthException('not_found', 'User not found.');

    final data = snap.data()!;
    final hash = data['password'] as String?;
    if (hash == null || !_verifyPassword(oldPassword, hash)) {
      throw AuthException('wrong_password', 'Old password is incorrect.');
    }

    await ref.update({'password': _hashPassword(newPassword)});
  }

  /// Rename username (keeps uniqueness via transaction).
  Future<void> changeUsername({required String userId, required String newUsername}) async {
    final newU = _normalize(newUsername);
    _assertValidUsername(newU);

    await _db.runTransaction((tx) async {
      final userRef = _users.doc(userId);
      final userSnap = await tx.get(userRef);
      if (!userSnap.exists) {
        throw AuthException('not_found', 'User not found.');
      }

      final oldUsername = (userSnap.data()?['username'] as String).toLowerCase();
      final oldIndexRef = _usernameIndexRef(oldUsername);
      final newIndexRef = _usernameIndexRef(newU);

      final newIndexSnap = await tx.get(newIndexRef);
      if (newIndexSnap.exists) {
        throw AuthException('username_taken', 'Username is already in use.');
      }

      // Create new index, update user, remove old index
      tx.set(newIndexRef, {'userId': userId, 'createdAt': FieldValue.serverTimestamp()});
      tx.update(userRef, {'username': newU});
      tx.delete(oldIndexRef);
    });
  }

  /// Delete account (removes user doc and username index atomically).
  Future<void> deleteAccount({required String userId}) async {
    await _db.runTransaction((tx) async {
      final userRef = _users.doc(userId);
      final userSnap = await tx.get(userRef);
      if (!userSnap.exists) return;

      final uname = (userSnap.data()?['username'] as String).toLowerCase();
      final idxRef = _usernameIndexRef(uname);

      tx.delete(userRef);
      tx.delete(idxRef);
    });
  }

  Future<void> logout() async {}
}
