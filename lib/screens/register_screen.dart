import 'package:flutter/material.dart';
import 'package:college_campus/models/app_user.dart';
import 'package:college_campus/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _rollNoCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _year = 'FE';
  String _division = 'A';
  TeacherType _teacherType = TeacherType.classTeacher;
  final Set<String> _selectedDivisions = {};
  bool _loading = false;
  bool _obscure = true;

  static const _years = ['FE', 'SE', 'TE', 'BE'];
  static const _divisions = ['A', 'B', 'C'];

  bool get _isStudent => widget.role == UserRole.student;

  bool get _isSubjectTeacher =>
      widget.role == UserRole.teacher &&
      _teacherType == TeacherType.subjectTeacher;

  String get _roleName => widget.role.name[0].toUpperCase() +
      widget.role.name.substring(1);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _rollNoCtrl.dispose();
    _subjectCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubjectTeacher && _selectedDivisions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one division.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.register(
        role: widget.role,
        email: _emailCtrl.text,
        password: _passCtrl.text,
        name: _nameCtrl.text,
        rollNo: _isStudent ? _rollNoCtrl.text.trim() : null,
        year: _year,
        division: _isSubjectTeacher ? null : _division,
        divisions: _isSubjectTeacher ? _selectedDivisions.toList() : null,
        teacherType: _teacherType,
        subject: widget.role == UserRole.teacher &&
                _subjectCtrl.text.trim().isNotEmpty
            ? _subjectCtrl.text.trim()
            : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Registration submitted. Awaiting approval.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$_roleName Registration')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: _isStudent ? 'Full Name' : 'Teacher Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter name' : null,
                  ),
                  if (_isStudent) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rollNoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'College Roll No',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter roll number'
                          : null,
                    ),
                  ],
                  if (widget.role == UserRole.teacher) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TeacherType>(
                      initialValue: _teacherType,
                      decoration: const InputDecoration(
                        labelText: 'Teacher Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: TeacherType.classTeacher,
                          child: Text('Class Teacher'),
                        ),
                        DropdownMenuItem(
                          value: TeacherType.subjectTeacher,
                          child: Text('Subject Teacher'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _teacherType = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subjectCtrl,
                      decoration: InputDecoration(
                        labelText: _teacherType == TeacherType.subjectTeacher
                            ? 'Subject'
                            : 'Subject (optional)',
                        prefixIcon:
                            const Icon(Icons.menu_book_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (_teacherType == TeacherType.subjectTeacher &&
                            (v == null || v.trim().isEmpty)) {
                          return 'Enter subject';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _year,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(),
                          ),
                          items: _years
                              .map((y) =>
                                  DropdownMenuItem(value: y, child: Text(y)))
                              .toList(),
                          onChanged: (v) => setState(() => _year = v!),
                        ),
                      ),
                      if (!_isSubjectTeacher) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _division,
                            decoration: const InputDecoration(
                              labelText: 'Division',
                              border: OutlineInputBorder(),
                            ),
                            items: _divisions
                                .map((d) => DropdownMenuItem(
                                    value: d, child: Text(d)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _division = v!),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_isSubjectTeacher) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Divisions you teach',
                          style:
                              Theme.of(context).textTheme.labelLarge),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _divisions.map((d) {
                        final selected = _selectedDivisions.contains(d);
                        return FilterChip(
                          label: Text('Division $d'),
                          selected: selected,
                          onSelected: (v) => setState(() {
                            v
                                ? _selectedDivisions.add(d)
                                : _selectedDivisions.remove(d);
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Min 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscure,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v != _passCtrl.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Register'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status after registration: Pending approval',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
