import 'package:uuid/uuid.dart';

/// CBS Envelope represents a typed message in the CBS system
class Envelope {
  final String id;
  final String service;
  final String verb;
  final String schema;
  final Map<String, dynamic>? payload;
  final ErrorDetails? error;

  const Envelope({
    required this.id,
    required this.service,
    required this.verb,
    required this.schema,
    this.payload,
    this.error,
  });

  /// Create a new request envelope
  factory Envelope.newRequest({
    required String service,
    required String verb,
    required String schema,
    required Map<String, dynamic> payload,
  }) {
    return Envelope(
      id: const Uuid().v4(),
      service: service,
      verb: verb,
      schema: schema,
      payload: payload,
    );
  }

  /// Create a new success response envelope
  factory Envelope.newResponse({
    required String requestId,
    required String service,
    required String verb,
    required String schema,
    required Map<String, dynamic> payload,
  }) {
    return Envelope(
      id: requestId,
      service: service,
      verb: verb,
      schema: schema,
      payload: payload,
    );
  }

  /// Create a new error response envelope
  factory Envelope.newError({
    required String requestId,
    required String service,
    required String verb,
    required String schema,
    required ErrorDetails error,
  }) {
    return Envelope(
      id: requestId,
      service: service,
      verb: verb,
      schema: schema,
      error: error,
    );
  }

  /// Create envelope from JSON
  factory Envelope.fromJson(Map<String, dynamic> json) {
    return Envelope(
      id: json['id'] as String,
      service: json['service'] as String,
      verb: json['verb'] as String,
      schema: json['schema'] as String,
      payload: json['payload'] as Map<String, dynamic>?,
      error: json['error'] != null 
          ? ErrorDetails.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert envelope to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'service': service,
      'verb': verb,
      'schema': schema,
    };
    
    if (payload != null) {
      json['payload'] = payload;
    }
    
    if (error != null) {
      json['error'] = error!.toJson();
    }
    
    return json;
  }

  /// Check if this envelope represents an error
  bool get isError => error != null;

  /// Get the NATS subject for this envelope
  String get subject => 'cbs.$service.$verb';

  @override
  String toString() {
    return 'Envelope(id: $id, service: $service, verb: $verb, schema: $schema, '
           'payload: $payload, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Envelope &&
        other.id == id &&
        other.service == service &&
        other.verb == verb &&
        other.schema == schema &&
        _mapEquals(other.payload, payload) &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(id, service, verb, schema, payload, error);
  }

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Error details for envelope error responses
class ErrorDetails {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ErrorDetails({
    required this.code,
    required this.message,
    this.details,
  });

  /// Create error details from JSON
  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  /// Convert error details to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'code': code,
      'message': message,
    };
    
    if (details != null) {
      json['details'] = details;
    }
    
    return json;
  }

  /// Create new error details
  factory ErrorDetails.badRequest(String message, [Map<String, dynamic>? details]) {
    return ErrorDetails(code: 'BadRequest', message: message, details: details);
  }

  factory ErrorDetails.notFound(String message, [Map<String, dynamic>? details]) {
    return ErrorDetails(code: 'NotFound', message: message, details: details);
  }

  factory ErrorDetails.internal(String message, [Map<String, dynamic>? details]) {
    return ErrorDetails(code: 'Internal', message: message, details: details);
  }

  factory ErrorDetails.timeout(String message, [Map<String, dynamic>? details]) {
    return ErrorDetails(code: 'Timeout', message: message, details: details);
  }

  @override
  String toString() {
    return 'ErrorDetails(code: $code, message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ErrorDetails &&
        other.code == code &&
        other.message == message &&
        _mapEquals(other.details, details);
  }

  @override
  int get hashCode => Object.hash(code, message, details);

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
