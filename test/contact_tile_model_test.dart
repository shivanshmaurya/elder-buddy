import 'package:elder_buddy/features/contacts/models/contact_tile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContactTileModel', () {
    test('serializes and deserializes correctly', () {
      final original = ContactTileModel(
        nickname: 'Grandma',
        realName: 'Sonia Gupta',
        phoneNumber: '+15551234567',
        photoPath: '/storage/emulated/0/Pictures/grandma.png',
      );

      final json = original.toJson();
      final restored = ContactTileModel.fromJson(json);

      expect(restored.nickname, equals(original.nickname));
      expect(restored.realName, equals(original.realName));
      expect(restored.phoneNumber, equals(original.phoneNumber));
      expect(restored.photoPath, equals(original.photoPath));
    });

    test('copyWith updates provided fields only', () {
      final original = ContactTileModel(
        nickname: 'Buddy',
        phoneNumber: '+15559876543',
      );

      final updated = original.copyWith(
        nickname: 'Buddy Jr.',
        photoPath: '/tmp/buddy.png',
      );

      expect(updated.nickname, 'Buddy Jr.');
      expect(updated.phoneNumber, original.phoneNumber);
      expect(updated.photoPath, '/tmp/buddy.png');
      expect(updated.realName, original.realName);
    });
  });
}
