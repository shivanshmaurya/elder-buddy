import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/contacts/models/contact_tile_model.dart';

class ContactStorageService {
  static const String _storageKey = 'saved_contacts';

  static Future<List<ContactTileModel>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map(
              (item) => ContactTileModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> saveContacts(List<ContactTileModel> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((c) => c.toJson()).toList();
    final jsonString = json.encode(jsonList);
    return prefs.setString(_storageKey, jsonString);
  }

  static Future<bool> addContact(ContactTileModel contact) async {
    final contacts = await loadContacts();

    // Check if contact already exists (by phone number)
    final exists = contacts.any((c) => c.phoneNumber == contact.phoneNumber);
    if (exists) {
      return false;
    }

    contacts.add(contact);
    return saveContacts(contacts);
  }

  static Future<bool> removeContact(String phoneNumber) async {
    final contacts = await loadContacts();
    contacts.removeWhere((c) => c.phoneNumber == phoneNumber);
    return saveContacts(contacts);
  }

  static Future<bool> updateContact(ContactTileModel contact) async {
    final contacts = await loadContacts();
    final index =
        contacts.indexWhere((c) => c.phoneNumber == contact.phoneNumber);

    if (index == -1) {
      return false;
    }

    contacts[index] = contact;
    return saveContacts(contacts);
  }
}
