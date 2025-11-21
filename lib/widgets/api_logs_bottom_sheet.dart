import 'package:flutter/material.dart';
import '../models/api_call.dart';

class ApiLogsBottomSheet extends StatelessWidget {
  final List<ApiCall> apiCalls;

  const ApiLogsBottomSheet({
    super.key,
    required this.apiCalls,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'API Calls Log',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total: ${apiCalls.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          // List of API calls
          Expanded(
            child: apiCalls.isEmpty
                ? const Center(
                    child: Text(
                      'No API calls recorded',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: apiCalls.length,
                    itemBuilder: (context, index) {
                      final apiCall = apiCalls[index];
                      return _ApiCallItem(apiCall: apiCall);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ApiCallItem extends StatefulWidget {
  final ApiCall apiCall;

  const _ApiCallItem({required this.apiCall});

  @override
  State<_ApiCallItem> createState() => _ApiCallItemState();
}

class _ApiCallItemState extends State<_ApiCallItem> {
  bool _isExpanded = false;

  Color _getStatusColor(int? statusCode) {
    if (statusCode == null) return Colors.red;
    if (statusCode >= 200 && statusCode < 300) return Colors.green;
    if (statusCode >= 300 && statusCode < 400) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final apiCall = widget.apiCall;
    final statusColor = _getStatusColor(apiCall.statusCode);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Method badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getMethodColor(apiCall.method),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      apiCall.method,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status code
                  if (apiCall.statusCode != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${apiCall.statusCode}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Duration
                  if (apiCall.duration != null)
                    Text(
                      '${apiCall.duration!.inMilliseconds}ms',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
            // URL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                apiCall.url,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),
            ),
            // Expanded details
            if (_isExpanded) ...[
              const Divider(),
              // Headers
              if (apiCall.headers != null && apiCall.headers!.isNotEmpty)
                _DetailSection(
                  title: 'Headers',
                  content: apiCall.headers!
                      .map((key, value) => MapEntry(key, '$key: $value'))
                      .values
                      .join('\n'),
                ),
              // Request Body
              if (apiCall.requestBody != null &&
                  apiCall.requestBody!.isNotEmpty)
                _DetailSection(
                  title: 'Request Body',
                  content: apiCall.requestBody!,
                ),
              // Response Body
              if (apiCall.responseBody != null &&
                  apiCall.responseBody!.isNotEmpty)
                _DetailSection(
                  title: 'Response Body',
                  content: apiCall.responseBody!,
                ),
              // Timestamp
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Time: ${apiCall.timestamp.toString()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;

  const _DetailSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              content,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

