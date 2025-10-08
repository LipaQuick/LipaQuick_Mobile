import 'package:flutter/foundation.dart';

enum APIError {
  NONE(0),
  BAD_REQUEST(400),
  UN_AUTHORIZED(401),
  FORBIDDEN(403),
  NOT_FOUND(404),
  INTERNAL_SERVER_ERROR(500),
  UN_AVAILABLE(503),
  SYSTEM_ERROR(1),
  PERMISSION_UNAVAILABLE(2),
  PERMISSION_DENIED(3),
  PERMISSION_DENIED_FOREVER(4),
  INTERNET_NOT_AVAILABLE(5);


  final num value;
  const APIError(this.value);
}

extension ApiErrorDesc on APIError {
  String get name => describeEnum(this);
}

class APIException implements Exception {
  final String? message;
  final int? statusCode;
  final APIError apiError;
  final List<String>? errors;

  const APIException(this.message, this.statusCode, this.apiError,[this.errors]);

  static const empty = APIException('', -1, APIError.NONE, []);

  @override
  String toString() {
    return 'APIException: message: $message'
        ', statusCode: $statusCode'
        ', API Error: $apiError'
        ', Errors: ${errors.toString()}'
    ;
  }
}
