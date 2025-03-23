// Base exception class
class AppException implements Exception {
  final String message;
  
  AppException(this.message);
  
  @override
  String toString() => message;
}

// Authentication related exceptions
class AppAuthException extends AppException {
  AppAuthException(String message) : super(message);
}

// Network related exceptions
class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

// API related exceptions
class ApiException extends AppException {
  final int statusCode;
  
  ApiException(String message, this.statusCode) : super(message);
  
  @override
  String toString() => '$message (Status code: $statusCode)';
}

// Specific HTTP status code exceptions
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

// Database related exceptions
class DatabaseException extends AppException {
  DatabaseException(String message) : super(message);
}

// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? errors;
  
  ValidationException(String message, {this.errors}) : super(message);
  
  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final errorString = errors!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return '$message ($errorString)';
    }
    return message;
  }
}

// Permission related exceptions
class PermissionException extends AppException {
  PermissionException(String message) : super(message);
}

// Location related exceptions
class LocationException extends AppException {
  LocationException(String message) : super(message);
}

// File related exceptions
class FileException extends AppException {
  FileException(String message) : super(message);
}

// Payment related exceptions
class PaymentException extends AppException {
  PaymentException(String message) : super(message);
}

// Not implemented exception
class NotImplementedException extends AppException {
  NotImplementedException([String message = 'This feature is not implemented yet.']) : super(message);
}

// Timeout exception
class TimeoutException extends NetworkException {
  TimeoutException([String message = 'The operation timed out.']) : super(message);
}