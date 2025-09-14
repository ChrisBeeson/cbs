/// Bus-level errors for CBS operations
abstract class BusError implements Exception {
  final String message;
  const BusError(this.message);

  /// Request timeout: no response received within deadline
  factory BusError.timeout([String? message]) = TimeoutError;

  /// Bad request
  factory BusError.badRequest(String message) = BadRequestError;

  /// Not found
  factory BusError.notFound(String message) = NotFoundError;

  /// Internal error
  factory BusError.internal(String message) = InternalError;

  /// Connection error
  factory BusError.connection(String message) = ConnectionError;

  /// Serialization error
  factory BusError.serialization(String message) = SerializationError;

  @override
  String toString() => '$runtimeType: $message';
}

/// Request timeout error
class TimeoutError extends BusError {
  const TimeoutError([String? message]) 
      : super(message ?? 'Request timeout: no response received within deadline');
}

/// Bad request error
class BadRequestError extends BusError {
  const BadRequestError(String message) : super(message);
}

/// Not found error
class NotFoundError extends BusError {
  const NotFoundError(String message) : super(message);
}

/// Internal error
class InternalError extends BusError {
  const InternalError(String message) : super(message);
}

/// Connection error
class ConnectionError extends BusError {
  const ConnectionError(String message) : super(message);
}

/// Serialization error
class SerializationError extends BusError {
  const SerializationError(String message) : super(message);
}
