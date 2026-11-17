import 'package:flutter/material.dart';
import 'package:college_campus/models/app_user.dart';
import 'package:college_campus/services/auth_service.dart';

class StudentDashboard extends StatelessWidget {
  final AppUser user;
  const StudentDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(user.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  _row(Icons.email_outlined, user.email),
                  if (user.rollNo != null)
                    _row(Icons.badge_outlined, 'Roll No: ${user.rollNo}'),
                  _row(Icons.class_outlined,
                      '${user.year ?? '-'} - Division ${user.division ?? '-'}'),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text('Status: ${user.status.name.toUpperCase()}'),
                    backgroundColor: Colors.green.shade100,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
