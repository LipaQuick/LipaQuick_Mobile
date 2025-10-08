import 'package:floor/floor.dart';

import '../../models/contacts/contacts.dart';

@dao
abstract class ContactsDao{
  @Query('Select * from ContactsAPI')
  Future<List<ContactsAPI>> getAllContacts();

  @Query('SELECT * from ContactsAPI WHERE name LIKE :query OR phoneNumber LIKE :query')
  Future<List<ContactsAPI>> getContactsByQuery(String query);

  @insert
  Future<void> insertContact(ContactsAPI contact);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertContacts(List<ContactsAPI> contacts);

  @Query('Delete from ContactsAPI')
  Future<void> deleteContacts();
}