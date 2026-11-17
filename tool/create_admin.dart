// ignore_for_file: avoid_print
// Creates the first Admin account for College Connect.
// Run:  dart run tool/create_admin.dart admin@college.edu YourPassword123 "Admin Name"
//
// Uses Firebase Auth + Firestore REST APIs, so no Flutter/plugin needed.
// Requires Firestore rules to allow a signed-in user to create their own
// `users/{uid}` doc (see firestore.rules). If rules are not deployed yet,
// temporarily set Firestore to test mode or run this right after deploying
// firestore.rules.

import 'dart:convert';
import 'dart:io';

const apiKey = 'AIzaSyAlKMHjSAGThqXBdARKUxkB8n4dmLoVKi0'; // web apiKey
const projectId = 'college-campus-b9041';

Future<Map<String, dynamic>> _post(
    String url, Map<String, dynamic> body,
    {String? bearerToken}) async {
  final client = HttpClient();
  try {
    final req = await client.postUrl(Uri.parse(url));
    req.headers.contentType = ContentType.json;
    if (bearerToken != null) {
      req.headers.set('Authorization', 'Bearer $bearerToken');
    }
    req.write(jsonEncode(body));
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    final json = jsonDecode(text) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception('HTTP ${res.statusCode}: $text');
    }
    return json;
  } finally {
    client.close();
  }
}

Future<void> main(List<String> args) async {
  if (args.length < 3) {
    stderr.writeln(
        'Usage: dart run tool/create_admin.dart <email> <password> <name>');
    exit(1);
  }
  final email = args[0];
  final password = args[1];
  final name = args[2];

  String idToken;
  String uid;

  // Try sign up first; if the account already exists, sign in instead.
  try {
    final res = await _post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
      {'email': email, 'password': password, 'returnSecureToken': true},
    );
    idToken = res['idToken'];
    uid = res['localId'];
    print('Created auth account: $uid');
  } catch (_) {
    final res = await _post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
      {'email': email, 'password': password, 'returnSecureToken': true},
    );
    idToken = res['idToken'];
    uid = res['localId'];
    print('Signed in existing auth account: $uid');
  }

  await _post(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users?documentId=$uid',
    {
      'fields': {
        'role': {'stringValue': 'admin'},
        'status': {'stringValue': 'approved'},
        'email': {'stringValue': email},
        'name': {'stringValue': name},
        'createdAt': {
          'timestampValue': DateTime.now().toUtc().toIso8601String()
        },
      }
    },
    bearerToken: idToken,
  );

  print('Admin user created/updated in Firestore.');
  print('Login with email: $email');
}
