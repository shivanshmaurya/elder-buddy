import 'package:elder_buddy/features/contacts/models/contact_tile_model.dart';
import 'package:elder_buddy/storage/contact_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('returns empty list when no contacts stored', () async {
    final contacts = await ContactStorageService.loadContacts();
    expect(contacts, isEmpty);
  });

  test('handles add, update, and remove operations', () async {
    final contact = ContactTileModel(
      nickname: 'Grandchild',
      realName: 'Anya Patel',
      phoneNumber: '+15550001111',
    );

    final addResult = await ContactStorageService.addContact(contact);
    expect(addResult, isTrue);

    final stored = await ContactStorageService.loadContacts();
    expect(stored, hasLength(1));
    expect(stored.first.phoneNumber, contact.phoneNumber);

    final duplicateAdd = await ContactStorageService.addContact(contact);
    expect(duplicateAdd, isFalse);

    final updated = contact.copyWith(nickname: 'Anya');
    final updateResult = await ContactStorageService.updateContact(updated);
    expect(updateResult, isTrue);

    final afterUpdate = await ContactStorageService.loadContacts();
    expect(afterUpdate.first.nickname, equals('Anya'));

    final removeResult =
        await ContactStorageService.removeContact(contact.phoneNumber);
    expect(removeResult, isTrue);

    final emptyAfterRemove = await ContactStorageService.loadContacts();
    expect(emptyAfterRemove, isEmpty);
  });
}
