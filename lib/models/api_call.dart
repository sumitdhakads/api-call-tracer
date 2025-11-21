class ApiCall {
  final String id;
  final String url;
  final String method;
  final Map<String, String>? headers;
  final String? requestBody;
  final int? statusCode;
  final String? responseBody;
  final DateTime timestamp;
  final Duration? duration;

  ApiCall({
    required this.id,
    required this.url,
    required this.method,
    this.headers,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    required this.timestamp,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'method': method,
      'headers': headers,
      'requestBody': requestBody,
      'statusCode': statusCode,
      'responseBody': responseBody,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration?.inMilliseconds,
    };
  }

  factory ApiCall.fromJson(Map<String, dynamic> json) {
    return ApiCall(
      id: json['id'] as String,
      url: json['url'] as String,
      method: json['method'] as String,
      headers: json['headers'] != null
          ? Map<String, String>.from(json['headers'] as Map)
          : null,
      requestBody: json['requestBody'] as String?,
      statusCode: json['statusCode'] as int?,
      responseBody: json['responseBody'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
    );
  }
}

