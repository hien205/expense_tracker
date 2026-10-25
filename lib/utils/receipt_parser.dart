
class ReceiptParser {
  /// Lấy dòng đầu tiên có nội dung làm tên cửa hàng.
  static String extractMerchant(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    for (final line in lines) {
      final normalized = _normalize(line);

      final isNoise = RegExp(
        r'^(hoa don|receipt|invoice|tax invoice|'
        r'phone|tel|sdt|dt|date|ngay|bill no|ma hd)',
        caseSensitive: false,
      ).hasMatch(normalized);

      if (!isNoise && line.length >= 2) {
        return line;
      }
    }

    return '';
  }

  /// Trích xuất ngày, trả về dd/MM/yyyy.
  /// Hỗ trợ dd/MM/yyyy, dd-MM-yyyy, dd.MM.yyyy,
  /// yyyy-MM-dd và yyyy/MM/dd.
  static String extractDate(String text) {
    final patterns = [
      RegExp(
        r'\b([0-3]?\d)[/-]([01]?\d)[/-]((?:19|20)\d{2})\b',
      ),
      RegExp(
        r'\b([0-3]?\d)\.([01]?\d)\.((?:19|20)\d{2})\b',
      ),
      RegExp(
        r'\b((?:19|20)\d{2})-([01]?\d)-([0-3]?\d)\b',
      ),
      RegExp(
        r'\b((?:19|20)\d{2})/([01]?\d)/([0-3]?\d)\b',
      ),
    ];

    for (var i = 0; i < patterns.length; i++) {
      final match = patterns[i].firstMatch(text);
      if (match == null) continue;

      late int day;
      late int month;
      late int year;

      if (i < 2) {
        day = int.parse(match.group(1)!);
        month = int.parse(match.group(2)!);
        year = int.parse(match.group(3)!);
      } else {
        year = int.parse(match.group(1)!);
        month = int.parse(match.group(2)!);
        day = int.parse(match.group(3)!);
      }

      final date = DateTime.tryParse(
        '$year-${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}',
      );

      if (date == null ||
          date.year != year ||
          date.month != month ||
          date.day != day) {
        continue;
      }

      return '${day.toString().padLeft(2, '0')}/'
          '${month.toString().padLeft(2, '0')}/$year';
    }

    return '';
  }

  /// Ưu tiên dòng tổng tiền, tránh nhầm tiền thừa hoặc thuế.
  static int? extractTotal(String text) {
    final lines = text.split(RegExp(r'\r?\n'));

    final preferredKeywords = [
      'grand total',
      'total amount',
      'amount due',
      'total due',
      'tổng thanh toán',
      'tong thanh toan',
      'tổng cộng',
      'tong cong',
      'tổng tiền',
      'tong tien',
      'thành tiền',
      'thanh tien',
      'total',
      'thanh toán',
      'thanh toan',
    ];

    final excludedKeywords = [
      'subtotal',
      'sub total',
      'sub-total',
      'vat',
      'tax',
      'discount',
      'khuyến mãi',
      'khuyen mai',
      'tiền khách đưa',
      'tien khach dua',
      'tiền thừa',
      'tien thua',
      'tiền trả lại',
      'tien tra lai',
      'change',
      'cash',
    ];

    for (final keyword in preferredKeywords) {
      for (final line in lines) {
        final normalized = _normalize(line);

        if (!normalized.contains(_normalize(keyword))) {
          continue;
        }

        if (excludedKeywords.any(
          (word) => normalized.contains(_normalize(word)),
        )) {
          continue;
        }

        final amount = _extractAmountFromLine(line);

        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }

    return null;
  }

  /// Trích xuất các số tiền trên một dòng.
  static int? _extractAmountFromLine(String line) {
    final matches = RegExp(
      r'(?<![A-Za-z])\d[\d., ]*\d|\d{4,}',
    ).allMatches(line);

    final values = <int>[];

    for (final match in matches) {
      final raw = match.group(0)!.trim();

      // Loại bỏ dấu phân cách hàng nghìn.
      final digits = raw.replaceAll(RegExp(r'[.,\s]'), '');
      final value = int.tryParse(digits);

      if (value != null && value > 0) {
        values.add(value);
      }
    }

    if (values.isEmpty) return null;

    values.sort();
    return values.last;
  }

  /// Chuẩn hóa một số ký tự tiếng Việt để so sánh từ khóa.
  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('đ', 'd')
        .replaceAll(RegExp(r'[áàảãạăắằẳẵặâấầẩẫậ]'), 'a')
        .replaceAll(RegExp(r'[éèẻẽẹêếềểễệ]'), 'e')
        .replaceAll(RegExp(r'[íìỉĩị]'), 'i')
        .replaceAll(RegExp(r'[óòỏõọôốồổỗộơớờởỡợ]'), 'o')
        .replaceAll(RegExp(r'[úùủũụưứừửữự]'), 'u')
        .replaceAll(RegExp(r'[ýỳỷỹỵ]'), 'y');
  }
}
