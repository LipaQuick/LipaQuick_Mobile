class QrPaymentModel {
  UserDetails? _userDetails;
  BankDetails? _bankDetails;

  QrPaymentModel({UserDetails? userDetails, BankDetails? bankDetails}) {
    if (userDetails != null) {
      _userDetails = userDetails;
    }
    if (bankDetails != null) {
      _bankDetails = bankDetails;
    }
  }

  UserDetails? get userDetails => _userDetails;
  set userDetails(UserDetails? userDetails) => _userDetails = userDetails;
  BankDetails? get bankDetails => _bankDetails;
  set bankDetails(BankDetails? bankDetails) => _bankDetails = bankDetails;

  QrPaymentModel.fromJson(Map<String, dynamic> json) {
    _userDetails = json['UserDetails'] != null
        ? UserDetails.fromJson(json['UserDetails'])
        : null;
    _bankDetails = json['BankDetails'] != null
        ? BankDetails.fromJson(json['BankDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (_userDetails != null) {
      data['UserDetails'] = _userDetails!.toJson();
    }
    if (_bankDetails != null) {
      data['BankDetails'] = _bankDetails!.toJson();
    }
    return data;
  }
}

class UserDetails {
  String? _id;
  String? _userName;
  String? _role;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phoneNumber;
  String? _gender;
  String? _dateOfBirth;
  String? _address;
  String? _country;
  String? _state;
  String? _city;
  String? _street;
  String? _identityType;
  String? _identityNumber;
  String? _identityStatus;

  UserDetails(
      {String? userName,
        String? id,
        String? role,
        String? firstName,
        String? lastName,
        String? email,
        String? phoneNumber,
        String? gender,
        String? dateOfBirth,
        String? address,
        String? country,
        String? state,
        String? city,
        String? street,
        String? identityType,
        String? identityNumber,
        String? identityStatus}) {
    if (userName != null) {
      _userName = userName;
    }
    if (id != null) {
      _id = id;
    }
    if (role != null) {
      _role = role;
    }
    if (firstName != null) {
      _firstName = firstName;
    }
    if (lastName != null) {
      _lastName = lastName;
    }
    if (email != null) {
      _email = email;
    }
    if (phoneNumber != null) {
      _phoneNumber = phoneNumber;
    }
    if (gender != null) {
      _gender = gender;
    }
    if (dateOfBirth != null) {
      _dateOfBirth = dateOfBirth;
    }
    if (address != null) {
      _address = address;
    }
    if (country != null) {
      _country = country;
    }
    if (state != null) {
      _state = state;
    }
    if (city != null) {
      _city = city;
    }
    if (street != null) {
      _street = street;
    }
    if (identityType != null) {
      _identityType = identityType;
    }
    if (identityNumber != null) {
      _identityNumber = identityNumber;
    }
    if (identityStatus != null) {
      _identityStatus = identityStatus;
    }
  }

  String? get id => _id;
  set id(String? id) => _id = id;
  String? get userName => _userName;
  set userName(String? userName) => _userName = userName;
  String? get role => _role;
  set role(String? role) => _role = role;
  String? get firstName => _firstName;
  set firstName(String? firstName) => _firstName = firstName;
  String? get lastName => _lastName;
  set lastName(String? lastName) => _lastName = lastName;
  String? get email => _email;
  set email(String? email) => _email = email;
  String? get phoneNumber => _phoneNumber;
  set phoneNumber(String? phoneNumber) => _phoneNumber = phoneNumber;
  String? get gender => _gender;
  set gender(String? gender) => _gender = gender;
  String? get dateOfBirth => _dateOfBirth;
  set dateOfBirth(String? dateOfBirth) => _dateOfBirth = dateOfBirth;
  String? get address => _address;
  set address(String? address) => _address = address;
  String? get country => _country;
  set country(String? country) => _country = country;
  String? get state => _state;
  set state(String? state) => _state = state;
  String? get city => _city;
  set city(String? city) => _city = city;
  String? get street => _street;
  set street(String? street) => _street = street;
  String? get identityType => _identityType;
  set identityType(String? identityType) => _identityType = identityType;
  String? get identityNumber => _identityNumber;
  set identityNumber(String? identityNumber) =>
      _identityNumber = identityNumber;
  String? get identityStatus => _identityStatus;
  set identityStatus(String? identityStatus) =>
      _identityStatus = identityStatus;

  UserDetails.fromJson(Map<String, dynamic> json) {
    _id = json['Id'] ?? json['id'];
    _userName = json['UserName'];
    _role = json['Role'];
    _firstName = json['FirstName'];
    _lastName = json['LastName'];
    _email = json['Email'];
    _phoneNumber = json['PhoneNumber'];
    _gender = json['Gender'];
    _dateOfBirth = json['DateOfBirth'];
    _address = json['Address'];
    _country = json['Country'];
    _state = json['State'];
    _city = json['City'];
    _street = json['Street'];
    _identityType = json['IdentityType'];
    _identityNumber = json['IdentityNumber'];
    _identityStatus = json['IdentityStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['Id'] = _id;
    data['UserName'] = _userName;
    data['Role'] = _role;
    data['FirstName'] = _firstName;
    data['LastName'] = _lastName;
    data['Email'] = _email;
    data['PhoneNumber'] = _phoneNumber;
    data['Gender'] = _gender;
    data['DateOfBirth'] = _dateOfBirth;
    data['Address'] = _address;
    data['Country'] = _country;
    data['State'] = _state;
    data['City'] = _city;
    data['Street'] = _street;
    data['IdentityType'] = _identityType;
    data['IdentityNumber'] = _identityNumber;
    data['IdentityStatus'] = _identityStatus;
    return data;
  }
}

class BankDetails {
  String? _id;
  String? _bank;
  String? _swiftCode;
  String? _accountNumber;
  String? _accountHolderName;
  bool? _primary;

  BankDetails(
      {String? id,
        String? bank,
        String? swiftCode,
        String? accountNumber,
        String? accountHolderName,
        bool? primary}) {
    if (id != null) {
      _id = id;
    }
    if (bank != null) {
      _bank = bank;
    }
    if (swiftCode != null) {
      _swiftCode = swiftCode;
    }
    if (accountNumber != null) {
      _accountNumber = accountNumber;
    }
    if (accountHolderName != null) {
      _accountHolderName = accountHolderName;
    }
    if (primary != null) {
      _primary = primary;
    }
  }

  String? get id => _id;
  set id(String? id) => _id = id;
  String? get bank => _bank;
  set bank(String? bank) => _bank = bank;
  String? get swiftCode => _swiftCode;
  set swiftCode(String? swiftCode) => _swiftCode = swiftCode;
  String? get accountNumber => _accountNumber;
  set accountNumber(String? accountNumber) => _accountNumber = accountNumber;
  String? get accountHolderName => _accountHolderName;
  set accountHolderName(String? accountHolderName) =>
      _accountHolderName = accountHolderName;
  bool? get primary => _primary;
  set primary(bool? primary) => _primary = primary;

  BankDetails.fromJson(Map<String, dynamic> json) {
    _id = json['Id'];
    _bank = json['Bank'];
    _swiftCode = json['SwiftCode'];
    _accountNumber = json['AccountNumber'];
    _accountHolderName = json['AccountHolderName'];
    _primary = json['Primary'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = _id;
    data['Bank'] = _bank;
    data['SwiftCode'] = _swiftCode;
    data['AccountNumber'] = _accountNumber;
    data['AccountHolderName'] = _accountHolderName;
    data['Primary'] = _primary;
    return data;
  }
}