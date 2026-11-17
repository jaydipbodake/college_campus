import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:college_campus/screens/role_selection_screen.dart';

void main() {
  testWidgets('Role selection shows Admin, Teacher and Student',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Teacher'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
  });
}
