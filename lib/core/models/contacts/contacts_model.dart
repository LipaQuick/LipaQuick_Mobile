import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:floor/floor.dart';

@entity
class Contacts{
  @primaryKey
  String? id;
  String? name, phoneNumber;


  Contacts(this.id, this.name, this.phoneNumber);

  Contacts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phoneNumber'] = phoneNumber;
    return data;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contacts &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ phoneNumber.hashCode;

  @override
  String toString() {
    return 'Contacts{id: $id, name: $name, phoneNumber: $phoneNumber}';
  }
}