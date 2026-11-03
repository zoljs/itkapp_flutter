import 'package:flutter_test/flutter_test.dart';
import 'package:itk_app/domain/models/site_color.dart';

void main() {
  group('SiteColor.fromKey', () {
    test('known key returns its color', () {
      expect(SiteColor.fromKey('green'), SiteColor.green);
      expect(SiteColor.fromKey('itk'), SiteColor.itk);
    });

    test('null falls back to itk', () {
      expect(SiteColor.fromKey(null), SiteColor.itk);
    });

    test('unknown key falls back to itk', () {
      expect(SiteColor.fromKey('pink'), SiteColor.itk);
    });

    test('keys are case-sensitive', () {
      expect(SiteColor.fromKey('Green'), SiteColor.itk);
    });

    test('every value round-trips through its name', () {
      for (final color in SiteColor.values) {
        expect(SiteColor.fromKey(color.name), color);
      }
    });
  });
}
