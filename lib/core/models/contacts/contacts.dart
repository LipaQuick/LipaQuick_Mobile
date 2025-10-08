import 'package:floor/floor.dart';

@entity
class ContactsAPI{
  String? id;
  String? name;
  @primaryKey
  String? phoneNumber;
  @ignore
  String? profilePicture;
  String? role;
  String? bank, accountHolderName, swiftCode, accountNumber;

  ContactsAPI(this.id, this.name, this.phoneNumber, this.bank
      , this.accountHolderName, this.swiftCode, this.accountNumber);

  ContactsAPI.name(this.id, this.name, this.phoneNumber,this.profilePicture, this.bank
      , this.accountHolderName, this.swiftCode, this.accountNumber);

  ContactsAPI.fromJson(Map<String, dynamic> json) {
    //user is null, then customer is not registered on lipaquick
    id = json['id'] ?? '';
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    bank = json['bank'];
    profilePicture = json['profilePicture'];
    accountHolderName = json['accountHolderName'];
    swiftCode = json['swiftCode'];
    accountNumber = json['accountNumber'];
    role = json['role'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phoneNumber'] = phoneNumber;
    data['profilePicture'] = profilePicture;
    data['bank'] = bank;
    data['accountHolderName'] = accountHolderName;
    data['swiftCode'] = swiftCode;
    data['accountNumber'] = accountNumber;
    data['role'] = role;
    return data;
  }

  String getProfilePictureLogo(){
    var base64Image = profilePicture!.split(",");
    return base64Image.last;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ContactsAPI &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              accountNumber == other.accountNumber &&
              phoneNumber == other.phoneNumber;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ phoneNumber.hashCode ^ accountNumber.hashCode;

  @override
  String toString() {
    return 'Contacts{id: $id, name: $name, phoneNumber: $phoneNumber, accountNumber: $accountNumber}';
  }
}