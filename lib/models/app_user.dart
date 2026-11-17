import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, teacher, student }

enum UserStatus { pending, approved, rejected }

enum TeacherType { classTeacher, subjectTeacher }

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final UserStatus status;
  final String? rollNo;
  final String? year;
  final String? division;
  final List<String> divisions;
  final TeacherType teacherType;
  final String? subject;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    this.rollNo,
    this.year,
    this.division,
    this.divisions = const [],
    this.teacherType = TeacherType.classTeacher,
    this.subject,
  });

  bool get isClassTeacher =>
      role == UserRole.teacher && teacherType == TeacherType.classTeacher;

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return AppUser(
      uid: doc.id,
      email: d['email'] ?? '',
      name: d['name'] ?? '',
      role: UserRole.values.byName(d['role'] ?? 'student'),
      status: UserStatus.values.byName(d['status'] ?? 'pending'),
      rollNo: d['rollNo'],
      year: d['year'],
      division: d['division'],
      divisions: (d['divisions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      teacherType:
          TeacherType.values.byName(d['type'] ?? 'classTeacher'),
      subject: d['subject'],
    );
  }
}
