// Basic unit tests for the Hackathon app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hackathlone_app/core/constants/app_strings.dart';

void main() {
  group('App Constants Tests', () {
    test('App strings are defined correctly', () {
      expect(AppStrings.appTitle, isNotEmpty);
      expect(AppStrings.appTitle, equals('Hackathlone App'));
    });

    test('Authentication strings work', () {
      expect(AppStrings.loginTitle, equals('Welcome Back'));
      expect(AppStrings.emailLabel, equals('Email'));
      expect(AppStrings.passwordLabel, equals('Password'));
    });
  });

  group('Basic Widget Tests', () {
    test('Widget key generation works', () {
      final key1 = Key('test_key_1');
      final key2 = Key('test_key_2');

      expect(key1.toString(), contains('test_key_1'));
      expect(key2.toString(), contains('test_key_2'));
      expect(key1 != key2, isTrue);
    });
  });
}
