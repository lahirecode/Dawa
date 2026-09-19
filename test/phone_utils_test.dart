import 'package:flutter_test/flutter_test.dart';
import 'package:dawa/services/db_manager.dart';

void main() {
  group('Dbmanager phone normalization', () {
    test('normalizes local numbers using a selected country prefix', () {
      const prefix = '+243';

      expect(Dbmanager.normalizeTelephone('812345678', prefix), '+243812345678');
      expect(Dbmanager.normalizeTelephone('+243 812 345 678', prefix), '+243812345678');
      expect(Dbmanager.normalizeTelephone('243812345678', prefix), '+243812345678');
      expect(Dbmanager.normalizeTelephone('0812345678', prefix), '+243812345678');
      expect(Dbmanager.normalizeTelephone('00 243 812 345 678', prefix), '+243812345678');
    });

    test('keeps international numbers already normalized', () {
      expect(Dbmanager.normalizeTelephone('+33712345678', '+33'), '+33712345678');
      expect(Dbmanager.normalizeTelephone('33712345678', '+33'), '+33712345678');
    });
  });
}
