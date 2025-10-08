class ServiceApiResponse {
  final bool status;
  final String message;
  final List<ServiceChargeCommissionModel> data;
  //List<Data>? chargeData;

  ServiceApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ServiceApiResponse.fromJson(Map<String, dynamic> json) {
    return ServiceApiResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          !.map((e) => ServiceChargeCommissionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceChargeCommissionModel {
  final String serviceId;
  final String serviceCommissionId;
  final int flatAmount;
  final int amountPercentage;
  final int serviceChargeAmount;
  final int serviceCommissionAmount;
  final int totalAmount;

  ServiceChargeCommissionModel({
    required this.serviceId,
    required this.serviceCommissionId,
    required this.flatAmount,
    required this.amountPercentage,
    required this.serviceChargeAmount,
    required this.serviceCommissionAmount,
    required this.totalAmount,
  });

  factory ServiceChargeCommissionModel.fromJson(Map<String, dynamic> json) {
    return ServiceChargeCommissionModel(
      serviceId: json['serviceId'] ?? '',
      serviceCommissionId: json['serviceCommissionId'] ?? '',
      flatAmount: json['flatAmount'] ?? 0,
      amountPercentage: json['amountPercentage'] ?? 0,
      serviceChargeAmount: json['serviceChargeAmount'] ?? 0,
      serviceCommissionAmount: json['serviceCommissionAmount'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
    );
  }
}
