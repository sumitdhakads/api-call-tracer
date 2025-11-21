import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/api_call.dart';

class ApiTrackerService {
  static final ApiTrackerService _instance = ApiTrackerService._internal();
  factory ApiTrackerService() => _instance;
  ApiTrackerService._internal();

  final List<ApiCall> _apiCalls = [];
  final StreamController<List<ApiCall>> _streamController =
      StreamController<List<ApiCall>>.broadcast();

  List<ApiCall> get apiCalls => List.unmodifiable(_apiCalls);
  Stream<List<ApiCall>> get apiCallsStream => _streamController.stream;

  void addApiCall(ApiCall apiCall) {
    _apiCalls.add(apiCall);
    _streamController.add(List.unmodifiable(_apiCalls));
  }

  void clearApiCalls() {
    _apiCalls.clear();
    _streamController.add([]);
  }

  void dispose() {
    _streamController.close();
  }
}

// HTTP Client wrapper to intercept API calls
class ApiTrackingClient extends http.BaseClient {
  final http.Client _client;
  final ApiTrackerService _trackerService;

  ApiTrackingClient(this._client, this._trackerService);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startTime = DateTime.now();
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Capture request details
    String? requestBody;
    if (request is http.Request) {
      requestBody = request.body;
    }

    // Create API call record
    final apiCall = ApiCall(
      id: requestId,
      url: request.url.toString(),
      method: request.method,
      headers: request.headers,
      requestBody: requestBody,
      timestamp: startTime,
    );

    try {
      // Send the request
      final response = await _client.send(request);

      // Capture response
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      // Read response body
      final responseBytes = await response.stream.toBytes();
      final responseBody = String.fromCharCodes(responseBytes);
      
      // Update API call with response details
      final updatedApiCall = ApiCall(
        id: apiCall.id,
        url: apiCall.url,
        method: apiCall.method,
        headers: apiCall.headers,
        requestBody: apiCall.requestBody,
        statusCode: response.statusCode,
        responseBody: responseBody,
        timestamp: apiCall.timestamp,
        duration: duration,
      );

      // Add to tracker
      _trackerService.addApiCall(updatedApiCall);

      // Return response with the body stream
      return http.StreamedResponse(
        Stream.value(responseBytes),
        response.statusCode,
        headers: response.headers,
        reasonPhrase: response.reasonPhrase,
        contentLength: responseBytes.length,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
      );
    } catch (e) {
      // Handle errors
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      final errorApiCall = ApiCall(
        id: apiCall.id,
        url: apiCall.url,
        method: apiCall.method,
        headers: apiCall.headers,
        requestBody: apiCall.requestBody,
        statusCode: null,
        responseBody: 'Error: $e',
        timestamp: apiCall.timestamp,
        duration: duration,
      );

      _trackerService.addApiCall(errorApiCall);
      rethrow;
    }
  }
}

