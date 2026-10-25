
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';
import '../utils/receipt_parser.dart';

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  final ImagePicker _picker = ImagePicker();

  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  final TextEditingController _merchantController =
      TextEditingController();

  final TextEditingController _dateController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final List<String> _categories = [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Hóa đơn',
    'Sức khỏe',
    'Giải trí',
    'Khác',
  ];

  File? _image;
  String _recognizedText = '';
  String _selectedCategory = 'Khác';

  bool _isProcessing = false;
  bool _isSaving = false;

  Future<void> scanReceipt(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile == null || !mounted) return;

      setState(() {
        _image = File(pickedFile.path);
        _recognizedText = '';
        _merchantController.clear();
        _dateController.clear();
        _amountController.clear();
        _selectedCategory = 'Khác';
        _isProcessing = true;
      });

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final result = await _recognizer.processImage(inputImage);

      if (!mounted) return;

      final merchant = ReceiptParser.extractMerchant(result.text);
      final date = ReceiptParser.extractDate(result.text);
      final amount = ReceiptParser.extractTotal(result.text);

      setState(() {
        _recognizedText = result.text;
        _merchantController.text = merchant;
        _dateController.text = date;
        _amountController.text = amount?.toString() ?? '';
        _isProcessing = false;
      });

      if (result.text.trim().isEmpty) {
        showMessage('Không nhận diện được chữ. Hãy thử ảnh rõ hơn.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      showMessage('Không thể nhận diện hóa đơn: $e');
    }
  }

  Future<String> saveImagePermanently(File image) async {
    final appDirectory = await getApplicationDocumentsDirectory();

    final receiptDirectory = Directory(
      p.join(appDirectory.path, 'receipts'),
    );

    if (!await receiptDirectory.exists()) {
      await receiptDirectory.create(recursive: true);
    }

    final fileName =
        'receipt_${DateTime.now().microsecondsSinceEpoch}'
        '${p.extension(image.path)}';

    final savedImage = await image.copy(
      p.join(receiptDirectory.path, fileName),
    );

    return savedImage.path;
  }

  Future<void> saveReceipt() async {
    if (_image == null) {
      showMessage('Bạn hãy chụp hoặc chọn ảnh hóa đơn trước.');
      return;
    }

    final merchant = _merchantController.text.trim();
    final date = _dateController.text.trim();
    final amountText = _amountController.text.trim();

    // Chấp nhận số tiền nhập như 120000 hoặc 120.000.
    final normalizedAmount = amountText.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    final amount = int.tryParse(normalizedAmount);

    if (merchant.isEmpty ||
        date.isEmpty ||
        amount == null ||
        amount <= 0) {
      showMessage(
        'Vui lòng kiểm tra tên cửa hàng, ngày và tổng tiền.',
      );
      return;
    }

    final dateMatch = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(date);

    if (dateMatch == null) {
      showMessage('Ngày phải có dạng dd/MM/yyyy.');
      return;
    }

    final day = int.parse(dateMatch.group(1)!);
    final month = int.parse(dateMatch.group(2)!);
    final year = int.parse(dateMatch.group(3)!);

    final parsedDate = DateTime.tryParse(
      '$year-${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}',
    );

    if (parsedDate == null ||
        parsedDate.year != year ||
        parsedDate.month != month ||
        parsedDate.day != day) {
      showMessage('Ngày không hợp lệ. Hãy kiểm tra lại.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final savedImagePath = await saveImagePermanently(_image!);

      await DatabaseHelper.instance.insertTransaction({
        'title': merchant,
        // Giao dịch hóa đơn được tính là khoản chi.
        'amount': -amount,
        'category': _selectedCategory,
        'date': '${year.toString().padLeft(4, '0')}-'
            '${month.toString().padLeft(2, '0')}-'
            '${day.toString().padLeft(2, '0')}',
        'receipt_image_path': savedImagePath,
      });

      if (!mounted) return;

      // Trả true để trang trước tải lại danh sách giao dịch.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showMessage('Không thể lưu hóa đơn: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _recognizer.close();
    _merchantController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF7866D5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét hóa đơn'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Quét hóa đơn bằng AI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ML Kit nhận diện chữ trực tiếp trên thiết bị. '
            'Hãy kiểm tra thông tin trước khi lưu.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isProcessing || _isSaving
                      ? null
                      : () => scanReceipt(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Chụp ảnh'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing || _isSaving
                      ? null
                      : () => scanReceipt(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Chọn ảnh'),
                ),
              ),
            ],
          ),

          if (_image != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _image!,
                height: 220,
                fit: BoxFit.contain,
              ),
            ),
          ],

          if (_isProcessing) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
            const Center(
              child: Text('Đang nhận diện hóa đơn...'),
            ),
          ],

          if (!_isProcessing && _image != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Kiểm tra thông tin hóa đơn',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bạn có thể sửa thông tin nếu OCR nhận diện sai.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Tên cửa hàng',
                prefixIcon: Icon(Icons.store_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _dateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Ngày mua (dd/MM/yyyy)',
                hintText: '20/10/2026',
                prefixIcon: Icon(Icons.calendar_month_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tổng tiền',
                hintText: 'Ví dụ: 120000',
                prefixIcon: Icon(Icons.payments_outlined),
                suffixText: 'VNĐ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Danh mục chi tiêu',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : saveReceipt,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving ? 'Đang lưu...' : 'Xác nhận và lưu',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text('Xem nội dung OCR gốc'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    _recognizedText.isEmpty
                        ? 'Không nhận diện được chữ.'
                        : _recognizedText,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
