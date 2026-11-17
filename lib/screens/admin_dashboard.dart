import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:college_campus/models/app_user.dart';
import 'package:college_campus/services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Teacher Requests'),
            Tab(text: 'Student Requests'),
          ]),
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
        body: TabBarView(children: [
          _PendingList(role: UserRole.teacher),
          _PendingList(role: UserRole.student),
        ]),
      ),
    );
  }
}

class _PendingList extends StatelessWidget {
  final UserRole role;
  const _PendingList({required this.role});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role.name)
        .where('status', isEqualTo: UserStatus.pending.name)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: query,
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
              child: Text('No pending ${role.name} requests.'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i];
            final u = AppUser.fromDoc(d);
            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                      role == UserRole.teacher
                          ? Icons.co_present
                          : Icons.person,
                      color: Colors.white),
                ),
                title: Text(u.name),
                subtitle: Text(
                    '${u.email}\n${role == UserRole.teacher ? '${u.teacherType == TeacherType.classTeacher ? 'Class Teacher${u.subject != null ? ' - ${u.subject}' : ''}' : 'Subject Teacher - ${u.subject ?? '-'}'} | ' : ''}'
                    '${u.year ?? '-'} - ${u.divisions.isNotEmpty ? 'Divisions ${u.divisions.join(', ')}' : 'Division ${u.division ?? '-'}'}'
                    '${u.rollNo != null ? ' | Roll: ${u.rollNo}' : ''}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle,
                          color: Colors.green),
                      tooltip: 'Approve',
                      onPressed: () => _setStatus(
                          context, d.id, UserStatus.approved),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      tooltip: 'Reject',
                      onPressed: () => _setStatus(
                          context, d.id, UserStatus.rejected),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setStatus(
      BuildContext context, String uid, UserStatus status) async {
    try {
      await AuthService.setStatus(uid, status);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }
}
