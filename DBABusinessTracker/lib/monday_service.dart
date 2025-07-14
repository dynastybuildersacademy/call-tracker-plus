
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MondayService {
  static const _apiUrl = 'https://api.monday.com/v2';

  final String apiKey = dotenv.env['MONDAY_API_KEY'] ?? '';
  final String boardId = dotenv.env['BOARD_ID'] ?? '';

  Map<String, String> get _headers => {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      };

  Future<http.Response> _post(String query,
      {Map<String, dynamic>? variables}) async {
    final body = {'query': query};
    if (variables != null) body['variables'] = variables;
    return await http.post(Uri.parse(_apiUrl),
        headers: _headers, body: jsonEncode(body));
  }

  // Create generic item
  Future<int?> createItem(
      {required String itemName, required Map<String, dynamic> columnValues}) async {
    final columnJson = jsonEncode(columnValues).replaceAll('"', '\"');
    final q = '''
      mutation {
        create_item(board_id: $boardId,
          item_name: "$itemName",
          column_values: "$columnJson") { id }
      }
    ''';
    final res = await _post(q);
    if (res.statusCode == 200) {
      final id =
          jsonDecode(res.body)['data']['create_item']['id'] as String?;
      return int.tryParse(id ?? '');
    } else {
      throw Exception('Monday API error: ${res.body}');
    }
  }

  /// Convenience helper for appointments
  Future<int?> createAppointment(
      {required String clientName,
      required String type,
      required DateTime dateTime,
      String notes = ''}) {
    return createItem(
      itemName: '$clientName – $type',
      columnValues: {
        'status': {'label': type},
        'date': {'date': dateTime.toIso8601String()},
        'long_text': {'text': notes}
      },
    );
  }

  /// Convenience helper for prospects
  Future<int?> createProspect({
    required String prospectName,
    required String contactInfo,
    String notes = '',
  }) {
    return createItem(
      itemName: prospectName,
      columnValues: {
        'phone': {'phone': contactInfo, 'countryShortName': 'US'},
        'long_text': {'text': notes}
      },
    );
  }
}
