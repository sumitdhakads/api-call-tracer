import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_tracker.dart';

void main() {
  runApp(
    ApiTracker(
      materialApp: MaterialApp(
        title: 'API Tracker Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ApiTestPage(),
      ),
    ),
  );
}

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final ApiTrackerService _trackerService = ApiTrackerService();
  final List<String> _logs = [];
  bool _isLoading = false;

  // Create HTTP client with API tracking
  late final http.Client _httpClient;

  @override
  void initState() {
    super.initState();
    // Create tracking client
    _httpClient = ApiTrackingClient(http.Client(), _trackerService);
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> _makeApiCall(String url, String method) async {
    setState(() {
      _isLoading = true;
      _logs.add('Making $method request to $url...');
    });

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _httpClient.get(Uri.parse(url));
          break;
        case 'POST':
          response = await _httpClient.post(
            Uri.parse(url),
            body: {'test': 'data'},
          );
          break;
        default:
          throw Exception('Unsupported method: $method');
      }

      setState(() {
        _logs.add('Response: ${response.statusCode} - ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
      });
    } catch (e) {
      setState(() {
        _logs.add('Error: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('API Tracker Test'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tap anywhere 10 times within 12 seconds to view API logs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Test API Calls:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _makeApiCall(
                        'https://jsonplaceholder.typicode.com/posts/1',
                        'GET',
                      ),
              icon: const Icon(Icons.get_app),
              label: const Text('GET Request'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _makeApiCall(
                        'https://jsonplaceholder.typicode.com/posts',
                        'POST',
                      ),
              icon: const Icon(Icons.send),
              label: const Text('POST Request'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _makeApiCall(
                        'https://jsonplaceholder.typicode.com/users/1',
                        'GET',
                      ),
              icon: const Icon(Icons.person),
              label: const Text('GET User'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                    // Make multiple API calls
                    for (int i = 1; i <= 5; i++) {
                      _makeApiCall(
                        'https://jsonplaceholder.typicode.com/posts/$i',
                        'GET',
                      );
                    }
                  },
              icon: const Icon(Icons.refresh),
              label: const Text('Make 5 API Calls'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_logs.isNotEmpty) ...[
              const Text(
                'Logs:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _logs
                      .map((log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              log,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
