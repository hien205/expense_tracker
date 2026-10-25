
import 'receipt_parser.dart';

void main() {
  const sampleReceipt = '''
CO.OPMART
Ngày mua: 15/04/2025
Sữa tươi       35000
Bánh mì        12000
TỔNG THANH TOÁN 117000đ
''';

  print('Cửa hàng: ${ReceiptParser.extractMerchant(sampleReceipt)}');
  print('Ngày: ${ReceiptParser.extractDate(sampleReceipt)}');
  print('Tổng tiền: ${ReceiptParser.extractTotal(sampleReceipt)}');
}
