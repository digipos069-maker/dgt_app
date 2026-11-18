import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('check production endpoints response', () async {
    final client = http.Client();

    // 1. Grades endpoint
    print('Testing /api/grades...');
    try {
      final gradesRes = await client.get(
        Uri.parse('https://api.digital-teachers.com/api/grades?order=desc'),
        headers: {'Accept': 'application/json'},
      );
      print('Grades status: ' + gradesRes.statusCode.toString());
      print('Grades content-type: ' + gradesRes.headers['content-type'].toString());
      print('Grades body preview: ' + gradesRes.body.substring(0, gradesRes.body.length > 200 ? 200 : gradesRes.body.length));
    } catch (e) {
      print('Grades error: ' + e.toString());
    }

    // 2. Lessons endpoint
    print('Testing /api/lessons...');
    try {
      final lessonsRes = await client.get(
        Uri.parse('https://api.digital-teachers.com/api/lessons?gradeId=12&subjectId=1&page=1&limit=10'),
        headers: {'Accept': '*/*'},
      );
      print('Lessons status: ' + lessonsRes.statusCode.toString());
      print('Lessons body preview: ' + lessonsRes.body.substring(0, lessonsRes.body.length > 200 ? 200 : lessonsRes.body.length));
    } catch (e) {
      print('Lessons error: ' + e.toString());
    }

    // 3. Exams types endpoint
    print('Testing /api/exams/types...');
    try {
      final examsRes = await client.get(
        Uri.parse('https://api.digital-teachers.com/api/exams/types'),
        headers: {'Accept': 'application/json'},
      );
      print('Exams status: ' + examsRes.statusCode.toString());
      print('Exams body preview: ' + examsRes.body.substring(0, examsRes.body.length > 200 ? 200 : examsRes.body.length));
    } catch (e) {
      print('Exams error: ' + e.toString());
    }

    // 4. Basic content endpoint
    print('Testing /api/basic-content...');
    try {
      final basicRes = await client.get(
        Uri.parse('https://api.digital-teachers.com/api/basic-content?subjectId=1&page=1&limit=10'),
        headers: {'Accept': 'application/json'},
      );
      print('Basic status: ' + basicRes.statusCode.toString());
      print('Basic body preview: ' + basicRes.body.substring(0, basicRes.body.length > 200 ? 200 : basicRes.body.length));
    } catch (e) {
      print('Basic error: ' + e.toString());
    }
  });
}
