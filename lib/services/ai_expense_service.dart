
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AiExpenseService {
  static const String _apiKey =
      String.fromEnvironment('GROQ_API_KEY');

  static const String _apiUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<String> analyzeExpenses({
    required int totalIncome,
    required int totalExpense,
    required List<Map<String, dynamic>> transactions,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'Chua cau hinh GROQ_API_KEY. '
        'Hay chay lai app voi --dart-define.',
      );
    }

    if (transactions.isEmpty) {
      return 'Ban chua co giao dich de phan tich.';
    }

    final expenseByCategory = <String, int>{};
    final transactionLines = <String>[];

    for (final item in transactions) {
      final amount = (item['amount'] as num?)?.toInt() ?? 0;
      final title = item['title']?.toString() ?? 'Giao dich';
      final category = item['category']?.toString() ?? 'Khac';
      final date = item['date']?.toString() ?? '';

      if (amount < 0) {
        expenseByCategory[category] =
            (expenseByCategory[category] ?? 0) + amount.abs();
      }

      transactionLines.add(
        '$date | $title | $category | '
        '${amount < 0 ? 'Chi' : 'Thu'}: ${amount.abs()} VND',
      );
    }

    final categorySummary = expenseByCategory.entries
        .map((entry) => '${entry.key}: ${entry.value} VND')
        .join('\n');

    final prompt = '''
Hay phan tich tinh hinh thu chi ca nhan dua tren du lieu sau.

Tong thu: $totalIncome VND
Tong chi: $totalExpense VND

Chi tieu theo danh muc:
$categorySummary

Danh sach giao dich:
${transactionLines.join('\n')}

Hay tra loi bang tieng Viet, gom:
1. Nhan xet tong quan thu chi.
2. Cac danh muc chi tieu dang ton nhieu tien.
3. Goi y tiet kiem cu the, thuc te.
4. Canh bao neu chi tieu vuot qua thu nhap.

Chi dua tren du lieu duoc cung cap. Neu chua du du lieu,
hay noi ro han che. Day la thong tin tham khao,
khong phai tu van dau tu.
''';

    final uri = Uri.parse(_apiUrl);

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'openai/gpt-oss-20b',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'Ban la tro ly phan tich thu chi ca nhan. '
                      'Tra loi ro rang, huu ich va bang tieng Viet.',
                },
                {
                  'role': 'user',
                  'content': prompt,
                },
              ],
              'temperature': 0.4,
              'max_tokens': 1200,
            }),
          )
          .timeout(const Duration(seconds: 45));

      final Map<String, dynamic> data;

      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception(
          'Phan hoi tu Groq khong phai JSON hop le. '
          'HTTP ${response.statusCode}.',
        );
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final error = data['error'];
        final message = error is Map
            ? error['message']?.toString()
            : null;

        throw Exception(
          'Groq API loi HTTP ${response.statusCode}: '
          '${message ?? response.body}',
        );
      }

      final choices = data['choices'];

      if (choices is! List || choices.isEmpty) {
        throw Exception('Groq khong tra ve ket qua phan tich.');
      }

      final choice = choices.first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>?;
      final result = message?['content']?.toString().trim();

      if (result == null || result.isEmpty) {
        throw Exception('Groq tra ve noi dung rong.');
      }

      return result;
    } on TimeoutException {
      throw Exception(
        'Het thoi gian cho Groq API. '
        'Hay kiem tra ket noi mang va thu lai.',
      );
    } on http.ClientException catch (e) {
      throw Exception(
        'Khong ket noi duoc den Groq API: ${e.message}. '
        'Hay kiem tra mang va ket noi cua Android Emulator.',
      );
    }
  }
}
