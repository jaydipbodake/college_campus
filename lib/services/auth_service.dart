import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:college_campus/models/app_user.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  static Future<AppUser?> getCurrentAppUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  /// Creates the Firebase Auth account and a `users/{uid}` doc with
  /// status = pending. Returns null on success message via exception.
  static Future<void> register({
    required UserRole role,
    required String email,
    required String password,
    required String name,
    String? rollNo,
    String? year,
    String? division,
    List<String>? divisions,
    TeacherType teacherType = TeacherType.classTeacher,
    String? subject,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      // One class teacher per year/division: reject if a pending or
      // approved class teacher already exists for this class.
      // Subject teachers are not restricted.
      if (role == UserRole.teacher &&
          teacherType == TeacherType.classTeacher) {
        final existing = await _db
            .collection('users')
            .where('role', isEqualTo: UserRole.teacher.name)
            .where('status', whereIn: [
              UserStatus.pending.name,
              UserStatus.approved.name,
            ])
            .where('year', isEqualTo: year)
            .where('division', isEqualTo: division)
            .limit(1)
            .get();
        if (existing.docs.isNotEmpty) {
          throw Exception(
              'A class teacher for $year - Division $division is already registered.');
        }
      }
      await _db.collection('users').doc(cred.user!.uid).set({
        'role': role.name,
        'email': email.trim(),
        'name': name.trim(),
        'status': UserStatus.pending.name,
        'rollNo': rollNo,
        'year': year,
        'division': division,
        'type': teacherType.name,
        'subject': subject,
        // Subject teachers may handle multiple divisions.
        'divisions': divisions,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _auth.signOut();
    } catch (_) {
      // Roll back the auth account so registration can be retried.
      await cred.user?.delete();
      rethrow;
    }
  }

  /// Signs in and returns the AppUser. Caller checks status.
  static Future<AppUser> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = await getCurrentAppUser();
    if (user == null) {
      await _auth.signOut();
      throw Exception('No user profile found. Contact admin.');
    }
    return user;
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<void> setStatus(String uid, UserStatus status) =>
      _db.collection('users').doc(uid).update({'status': status.name});
}
