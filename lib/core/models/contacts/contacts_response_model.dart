import 'package:json_annotation/json_annotation.dart';
import 'package:lipa_quick/core/models/response.dart';
import 'package:lipa_quick/core/utils/diff_utils.dart';
import 'contacts.dart';


class ContactsResponse{
  @JsonKey(name: 'message', defaultValue: '')
  String? message;
  @JsonKey(name: 'status', defaultValue: false)
  bool? status;
  List<ContactsAPI>? data;

  ContactsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'] as bool? ?? false;
    message = json['message'] as String? ?? '';
    data =  (json['data'] as List<dynamic>?)?.map((e) => ContactsAPI.fromJson(e as Map<String, dynamic>))
        .toList();
    if(data != null && data!.isNotEmpty){
      List<ContactsAPI>? uniqueContacts = data?.fold<Map<String, ContactsAPI>>({}, (map, contact) {
        String contactIdentifier = '${contact.phoneNumber}';
        map[contactIdentifier] = contact;
        return map;
      }).values.toList();

      data = uniqueContacts;
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['data'] = data;
    return data;
  }
}