import 'package:flutter_test/flutter_test.dart';
import 'package:isango_app/core/utils/auth_validators.dart';

void main() {
  group('AuthValidators.universityEmail', () {
    const expectedError = 'Please use a valid university email address';

    test('accepts a valid student email', () {
      expect(
        AuthValidators.universityEmail('student1@stud.ur.ac.rw'),
        isNull,
      );
    });

    test('accepts uppercase domain (case-insensitive)', () {
      expect(
        AuthValidators.universityEmail('jdoe_111@STUD.UR.AC.RW'),
        isNull,
      );
    });

    test('accepts a name with dots and digits', () {
      expect(
        AuthValidators.universityEmail('a.b.c123@stud.ur.ac.rw'),
        isNull,
      );
    });

    test('rejects gmail.com', () {
      expect(
        AuthValidators.universityEmail('student@gmail.com'),
        expectedError,
      );
    });

    test('rejects ur.ac.rw without stud subdomain', () {
      expect(
        AuthValidators.universityEmail('staff@ur.ac.rw'),
        expectedError,
      );
    });

    test('rejects empty string with required-message', () {
      expect(
        AuthValidators.universityEmail(''),
        'Email is required',
      );
    });

    test('rejects whitespace as empty', () {
      expect(
        AuthValidators.universityEmail('   '),
        'Email is required',
      );
    });

    test('rejects malformed input (missing @)', () {
      expect(
        AuthValidators.universityEmail('nshimyimana.stud.ur.ac.rw'),
        expectedError,
      );
    });

    test('rejects similar-but-wrong domain', () {
      expect(
        AuthValidators.universityEmail('jdoe@stud.ur.ac.com'),
        expectedError,
      );
    });
  });
}
