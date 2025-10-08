class RecentTransactionModel {
  bool? _status;
  Data? _data;
  String? _message;

  RecentTransactionModel({bool? status, Data? data, String? message}) {
    if (status != null) {
      this._status = status;
    }
    if (data != null) {
      this._data = data;
    }
    if (message != null) {
      this._message = message;
    }
  }

  bool? get status => _status;
  set status(bool? status) => _status = status;
  Data? get data => _data;
  set data(Data? data) => _data = data;
  String? get message => _message;
  set message(String? message) => _message = message;

  RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    _status = json['status'] ?? false;
    _message = json['message'] ?? '';
    _data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this._status;
    data['message'] = this._message;
    if (this._data != null) {
      data['data'] = this._data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Customers>? _merchants;
  List<Customers>? _customers;

  Data({List<Customers>? customers, List<Customers>? merchants}) {
    if (merchants != null) {
      this._merchants = merchants;
    }
    if (customers != null) {
      this._customers = customers;
    }
  }

  List<Customers>? get merchants => _merchants;
  set merchants(List<Customers>? merchants) => _merchants = merchants;
  List<Customers>? get customers => _customers;
  set customers(List<Customers>? customers) => _customers = customers;

  Data.fromJson(Map<String, dynamic> json) {
    _merchants = <Customers>[];
    if (json['merchants'] != null) {
      json['merchants'].forEach((v) {
        _merchants!.add(new Customers.fromJson(v));
      });
    }
    _customers = <Customers>[];
    if (json['customers'] != null) {
      json['customers'].forEach((v) {
        _customers!.add(new Customers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._merchants != null) {
      data['merchants'] = this._merchants!.map((v) => v.toJson()).toList();
    }
    if (this._customers != null) {
      data['customers'] = this._customers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Customers {
  String? _id;
  String? _name;
  String? _phoneNumber;
  String? _profilePicture;
  String? _bank;
  String? _accountHolderName;
  String? _swiftCode;
  String? _accountNumber;
  String? _createdAt;
  String? _createdBy;
  String? _modifiedAt;
  String? _modifiedBy;
  String? _latLng;
  int? _distance;

  Customers(
      {String? id,
        String? name,
        String? phoneNumber,
        String? profilePicture,
        String? bank,
        String? accountHolderName,
        String? swiftCode,
        String? accountNumber,
        String? createdAt,
        String? createdBy,
        String? modifiedAt,
        String? modifiedBy,
        String? latLng,
        int? distance}) {
    if (id != null) {
      this._id = id;
    }
    if (name != null) {
      this._name = name;
    }
    if (phoneNumber != null) {
      this._phoneNumber = phoneNumber;
    }
    if (profilePicture != null) {
      this._profilePicture = profilePicture;
    }
    if (bank != null) {
      this._bank = bank;
    }
    if (accountHolderName != null) {
      this._accountHolderName = accountHolderName;
    }
    if (swiftCode != null) {
      this._swiftCode = swiftCode;
    }
    if (accountNumber != null) {
      this._accountNumber = accountNumber;
    }
    if (createdAt != null) {
      this._createdAt = createdAt;
    }
    if (createdBy != null) {
      this._createdBy = createdBy;
    }
    if (modifiedAt != null) {
      this._modifiedAt = modifiedAt;
    }
    if (modifiedBy != null) {
      this._modifiedBy = modifiedBy;
    }
    if (latLng != null) {
      this._latLng = latLng;
    }
    if (distance != null) {
      this._distance = distance;
    }
  }

  String? get id => _id;
  set id(String? id) => _id = id;
  String? get name => _name;
  set name(String? name) => _name = name;
  String? get phoneNumber => _phoneNumber;
  set phoneNumber(String? phoneNumber) => _phoneNumber = phoneNumber;
  String? get profilePicture => _profilePicture;
  set profilePicture(String? profilePicture) => _profilePicture = profilePicture;
  String? get bank => _bank;
  set bank(String? bank) => _bank = bank;
  String? get accountHolderName => _accountHolderName;
  set accountHolderName(String? accountHolderName) =>
      _accountHolderName = accountHolderName;
  String? get swiftCode => _swiftCode;
  set swiftCode(String? swiftCode) => _swiftCode = swiftCode;
  String? get accountNumber => _accountNumber;
  set accountNumber(String? accountNumber) => _accountNumber = accountNumber;
  String? get createdAt => _createdAt;
  set createdAt(String? createdAt) => _createdAt = createdAt;
  String? get createdBy => _createdBy;
  set createdBy(String? createdBy) => _createdBy = createdBy;
  String? get modifiedAt => _modifiedAt;
  set modifiedAt(String? modifiedAt) => _modifiedAt = modifiedAt;
  String? get modifiedBy => _modifiedBy;
  set modifiedBy(String? modifiedBy) => _modifiedBy = modifiedBy;
  String? get latLng => _latLng;
  set latLng(String? latLng) => _latLng = latLng;
  int? get distance => _distance;
  set distance(int? distance) => _distance = distance;

  Customers.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _phoneNumber = json['phoneNumber'];
    _profilePicture = json['profilePicture'];
    _bank = json['bank'];
    _accountHolderName = json['accountHolderName'];
    _swiftCode = json['swiftCode'];
    _accountNumber = json['accountNumber'];
    _createdAt = json['createdAt'];
    _createdBy = json['createdBy'];
    _modifiedAt = json['modifiedAt'];
    _modifiedBy = json['modifiedBy'];
    _latLng = json['latLng'];
    _distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['name'] = this._name;
    data['phoneNumber'] = this._phoneNumber;
    data['profilePicture'] = this._profilePicture;
    data['bank'] = this._bank;
    data['accountHolderName'] = this._accountHolderName;
    data['swiftCode'] = this._swiftCode;
    data['accountNumber'] = this._accountNumber;
    data['createdAt'] = this._createdAt;
    data['createdBy'] = this._createdBy;
    data['modifiedAt'] = this._modifiedAt;
    data['modifiedBy'] = this._modifiedBy;
    data['latLng'] = this._latLng;
    data['distance'] = this._distance;
    return data;
  }
}