import 'package:flutter/material.dart';
import 'package:college_campus/models/app_user.dart';
import 'package:college_campus/screens/login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('College Connect')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.school, size: 72, color: Colors.indigo),
              const SizedBox(height: 16),
              Text(
                'CSE Department',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              _RoleButton(
                icon: Icons.admin_panel_settings,
                label: 'Admin',
                subtitle: 'Login only',
                color: Colors.red.shade700,
                onTap: () => _openLogin(context, UserRole.admin),
              ),
              const SizedBox(height: 16),
              _RoleButton(
                icon: Icons.co_present,
                label: 'Teacher',
                subtitle: 'Login + Register',
                color: Colors.blue.shade700,
                onTap: () => _openLogin(context, UserRole.teacher),
              ),
              const SizedBox(height: 16),
              _RoleButton(
                icon: Icons.person,
                label: 'Student',
                subtitle: 'Login + Register',
                color: Colors.green.shade700,
                onTap: () => _openLogin(context, UserRole.student),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLogin(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleLarge),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
