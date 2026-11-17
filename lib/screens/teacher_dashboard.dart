import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:college_campus/models/app_user.dart';
import 'package:college_campus/services/auth_service.dart';

class TeacherDashboard extends StatelessWidget {
  final AppUser user;
  const TeacherDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isClassTeacher = user.isClassTeacher;
    // Subject teachers may handle multiple divisions.
    final classLabel = isClassTeacher
        ? '${user.year} - Division ${user.division}'
        : '${user.year} - Divisions ${user.divisions.join(', ')}';

    // Class teacher: pending student approvals for their class.
    // Subject teacher: view-only list of approved students in their class.
    final Query<Map<String, dynamic>> query = isClassTeacher
        ? FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: UserRole.student.name)
            .where('status', isEqualTo: UserStatus.pending.name)
            .where('year', isEqualTo: user.year)
            .where('division', isEqualTo: user.division)
        : FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: UserRole.student.name)
            .where('status', isEqualTo: UserStatus.approved.name)
            .where('year', isEqualTo: user.year)
            .where('division',
                whereIn: user.divisions.isEmpty
                    ? const ['-']
                    : user.divisions);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isClassTeacher
              ? 'Class Teacher - $classLabel'
              : 'Subject Teacher - ${user.subject ?? '-'} ($classLabel)',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              isClassTeacher
                  ? 'Pending student registrations ($classLabel)'
                  : 'Students in $classLabel',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                      child: Text(isClassTeacher
                          ? 'No pending requests.'
                          : 'No approved students yet.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final u = AppUser.fromDoc(d);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: const CircleAvatar(
                            child: Icon(Icons.person)),
                        title: Text(u.name),
                        subtitle: Text(
                            '${u.email}\nRoll No: ${u.rollNo ?? '-'}'),
                        isThreeLine: true,
                        trailing: isClassTeacher
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    tooltip: 'Approve',
                                    onPressed: () => _setStatus(context,
                                        d.id, UserStatus.approved),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    tooltip: 'Reject',
                                    onPressed: () => _setStatus(context,
                                        d.id, UserStatus.rejected),
                                  ),
                                ],
                              )
                            : Chip(
                                label: Text(u.status.name),
                                backgroundColor:
                                    Colors.green.shade100,
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setStatus(
      BuildContext context, String uid, UserStatus status) async {
    try {
      await AuthService.setStatus(uid, status);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}
