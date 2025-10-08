
class NearByResponse{
  bool? status;
  String? message;
  List<MerchantLocationDetail>? data;

  NearByResponse({this.status,this.message, this.data});

  NearByResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MerchantLocationDetail>[];
      json['data'].forEach((v) {
        data!.add(MerchantLocationDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'NearByResponse{status: $status, message: $message}';
  }
}

class MerchantLocationDetail {
  String? id;
  String? name;
  String? profilePicture;
  String? bank;
  String? accountHolderName;
  String? swiftCode;
  String? accountNumber;
  String? createdAt;
  String? latLng;
  double? distance;

  MerchantLocationDetail({this.id, this.name, this.profilePicture, this.bank, this.accountHolderName, this.swiftCode, this.accountNumber, this.createdAt, this.latLng, this.distance});


  MerchantLocationDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profilePicture = json['profilePicture'];
    bank = json['bank'];
    accountHolderName = json['accountHolderName'];
    swiftCode = json['swiftCode'];
    accountNumber = json['accountNumber'];
    createdAt = json['createdAt'];
    latLng = json['latLng'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profilePicture'] = profilePicture;
    data['bank'] = bank;
    data['accountHolderName'] = accountHolderName;
    data['swiftCode'] = swiftCode;
    data['accountNumber'] = accountNumber;
    data['createdAt'] = createdAt;
    data['latLng'] = latLng;
    data['distance'] = distance;
    return data;
  }
}