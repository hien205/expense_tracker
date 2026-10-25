import 'dart:io';

import 'package:flutter/material.dart';
import 'theme/theme_controller.dart';

import 'database/database_helper.dart';
import 'screens/receipt_scan_screen.dart';
import 'screens/ai_expense_screen.dart';
import 'dart:math' as math;
import 'screens/auth_screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

// Pastel pink + lavender theme
const Color primaryColor = Color(0xFF9B83D9);
const Color backgroundColor = Color(0xFFFFF8FB);
const Color pinkColor = Color(0xFFE99AB7);
const Color lightPink = Color(0xFFFFEFF5);
const Color lightPurple = Color(0xFFF0EBFF);
const Color textColor = Color(0xFF393047);
const Color secondaryText = Color(0xFF898197);
const Color greenColor = Color(0xFF65B99A);

const Map<String, Color> categoryColors = {
  'Ăn uống': Color(0xFFE99AB7),
  'Di chuyển': Color(0xFF79A9E8),
  'Mua sắm': Color(0xFF9B83D9),
  'Học tập': Color(0xFF65B99A),
  'Hóa đơn': Color(0xFF79A9E8),
  'Sức khỏe': Color(0xFFE58DAA),
  'Giải trí': Color(0xFFFFAE80),
  'Khác': Color(0xFFA49AB8),
};

class _StatisticsMiniCard extends StatelessWidget {
  final String label;
  final int amount;
  final IconData icon;
  final Color color;

  const _StatisticsMiniCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '${amount >= 1000000 ? (amount / 1000000).toStringAsFixed(1) : amount >= 1000 ? (amount / 1000).round().toString() : amount}${amount >= 1000000 ? 'tr' : amount >= 1000 ? 'k' : ''} đ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseDonutPainter extends CustomPainter {
  final List<MapEntry<String, int>> totals;
  final int total;

  _ExpenseDonutPainter({
    required this.totals,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 23
      ..strokeCap = StrokeCap.round;

    if (total <= 0 || totals.isEmpty) {
      paint.color = const Color(0xFFECE5F5);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi,
        false,
        paint,
      );
      return;
    }

    var startAngle = -math.pi / 2;

    for (final entry in totals) {
      final sweepAngle = entry.value / total * 2 * math.pi;

      paint.color = categoryColors[entry.key] ??
          categoryColors['Khác']!;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ExpenseDonutPainter oldDelegate) {
    return oldDelegate.total != total ||
        oldDelegate.totals != totals;
  }
}



class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  @override
  void initState() {
    super.initState();
    appThemeController.addListener(_onThemeChanged);
    appThemeController.load();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    appThemeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      themeMode: appThemeController.themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFF9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFECE3F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFECE3F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF17151D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF17151D),
          foregroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF26222F),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF26222F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF484052)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF484052)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}


class _AuthGateState extends State<AuthGate> {
  Map<String, dynamic>? _user;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  // Khôi phục phiên đăng nhập khi mở ứng dụng.
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId != null) {
        final user = await DatabaseHelper.instance.getUserById(userId);

        if (user != null) {
          if (!mounted) return;

          setState(() {
            _user = {
              'id': user['id'],
              'name': user['name'],
              'email': user['email'],
            };
          });
        } else {
          await prefs.remove('user_id');
        }
      }
    } catch (e) {
      debugPrint('Lỗi khôi phục phiên đăng nhập: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });
      }
    }
  }

  Future<bool> _login(String email, String password) async {
    try {
      final user = await DatabaseHelper.instance
          .getUserByEmail(email.trim());

      if (user == null) return false;

      final passwordHash =
          sha256.convert(utf8.encode(password)).toString();

      if (user['password_hash'] != passwordHash) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user['id'] as int);

      if (!mounted) return false;

      setState(() {
        _user = {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
        };
      });

      return true;
    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
      return false;
    }
  }

  Future<bool> _register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      if (name.trim().isEmpty ||
          normalizedEmail.isEmpty ||
          password.isEmpty) {
        return false;
      }

      final existing = await DatabaseHelper.instance
          .getUserByEmail(normalizedEmail);

      if (existing != null) return false;

      final passwordHash =
          sha256.convert(utf8.encode(password)).toString();

      final userId = await DatabaseHelper.instance.registerUser(
        name: name.trim(),
        email: normalizedEmail,
        passwordHash: passwordHash,
      );

     // Đăng ký thành công, quay lại màn hình đăng nhập.
return true;
    } catch (e) {
      debugPrint('Lỗi đăng ký: $e');
      return false;
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    if (!mounted) return;

    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (_user == null) {
      return AuthScreen(
        onLogin: _login,
        onRegister: _register,
      );
    }

    return HomePage(
      user: _user!,
      onLogout: _logout,
    );
  }
}



class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  const HomePage({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<Map<String, dynamic>> transactions = [];
  bool isLoadingTransactions = true;
  String searchQuery = '';

  final List<String> expenseCategories = const [
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Học tập',
    'Hóa đơn',
    'Sức khỏe',
    'Giải trí',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  int get totalIncome => transactions.fold<int>(0, (sum, item) {
    final amount = (item['amount'] as num).toInt();
    return sum + (amount > 0 ? amount : 0);
  });

  int get totalExpense => transactions.fold<int>(0, (sum, item) {
    final amount = (item['amount'] as num).toInt();
    return sum + (amount < 0 ? amount.abs() : 0);
  });

  int get balance => totalIncome - totalExpense;

  String formatMoney(num amount) {
    final digits = amount.abs().round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${amount < 0 ? '-' : ''}${buffer.toString()}đ';
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

  IconData categoryIcon(String category, {bool income = false}) {
    if (income) return Icons.payments_rounded;

    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant_rounded;
      case 'Di chuyển':
        return Icons.directions_bus_rounded;
      case 'Mua sắm':
        return Icons.shopping_bag_rounded;
      case 'Học tập':
        return Icons.menu_book_rounded;
      case 'Hóa đơn':
        return Icons.receipt_long_rounded;
      case 'Sức khỏe':
        return Icons.health_and_safety_rounded;
      case 'Giải trí':
        return Icons.movie_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
  
  Future<void> loadTransactions() async {
    await DatabaseHelper.instance.seedDemoTransactions();
    if (mounted) {
      setState(() => isLoadingTransactions = true);
    }

    try {
      final rows = await DatabaseHelper.instance.getTransactions();

      final loaded = rows.map<Map<String, dynamic>>((row) {
        final amount = (row['amount'] as num).toInt();
        final category = row['category'] as String? ?? 'Khác';
        final income = amount > 0;

        return {
          'id': row['id'],
          'title': row['title'] as String? ?? 'Giao dịch',
          'subtitle': row['date'] as String? ?? '',
          'amount': amount,
          'icon': categoryIcon(category, income: income),
          'color': income
              ? greenColor
              : categoryColors[category] ?? categoryColors['Khác']!,
          'category': category,
          'receiptImagePath': row['receipt_image_path'] as String?,
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        transactions = loaded;
        isLoadingTransactions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoadingTransactions = false);
      showMessage('Không thể tải giao dịch: $e');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> openReceiptScanner() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ReceiptScanScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      await loadTransactions();
      if (!mounted) return;
      showMessage('Đã cập nhật giao dịch từ hóa đơn.');
    }
  }

  void openAiExpenseAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiExpenseScreen(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          transactions: transactions,
        ),
      ),
    );
  }

  Future<void> addTransaction() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    String type = 'Chi tiêu';
    String category = expenseCategories.first;
    bool saving = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Thêm giao dịch',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Tên giao dịch',
                      hintText: 'Ví dụ: Ăn sáng',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (VNĐ)',
                      hintText: 'Ví dụ: 30000',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(
                      labelText: 'Loại giao dịch',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Chi tiêu',
                        child: Text('Chi tiêu'),
                      ),
                      DropdownMenuItem(
                        value: 'Thu nhập',
                        child: Text('Thu nhập'),
                      ),
                    ],
                    onChanged: saving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setDialogState(() {
                              type = value;
                              category = value == 'Thu nhập'
                                  ? 'Thu nhập'
                                  : expenseCategories.first;
                            });
                          },
                  ),
                  if (type == 'Chi tiêu') ...[
                    const SizedBox(height: 13),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                      items: expenseCategories
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() => category = value);
                              }
                            },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        final amountText = amountController.text
                            .trim()
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        final amount = int.tryParse(amountText);

                        if (title.isEmpty || amount == null || amount <= 0) {
                          showMessage('Vui lòng nhập tên và số tiền hợp lệ.');
                          return;
                        }

                        setDialogState(() => saving = true);

                        try {
                          await DatabaseHelper.instance.insertTransaction({
                            'title': title,
                            'amount': type == 'Chi tiêu' ? -amount : amount,
                            'category': category,
                            'date': formatDate(DateTime.now()),
                            'receipt_image_path': null,
                          });

                          if (!mounted || !dialogContext.mounted) return;

                          Navigator.pop(dialogContext);
                          await loadTransactions();

                          if (!mounted) return;
                          showMessage('Đã lưu giao dịch thành công.');
                        } catch (e) {
                          if (!mounted) return;
                          setDialogState(() => saving = false);
                          showMessage('Không thể lưu giao dịch: $e');
                        }
                      },
                child: Text(saving ? 'Đang lưu...' : 'Lưu giao dịch'),
              ),
            ],
          ),
        ),
      );
    } finally {
      titleController.dispose();
      amountController.dispose();
    }
  }

  Future<void> deleteTransaction(Map<String, dynamic> item) async {
    final id = item['id'];

    if (id is! int) {
      showMessage('Không tìm thấy mã giao dịch.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: Text('Bạn có muốn xóa "${item['title']}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD96D8D),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      if (!mounted) return;
      await loadTransactions();
      if (!mounted) return;
      showMessage('Đã xóa giao dịch.');
    } catch (e) {
      if (!mounted) return;
      showMessage('Không thể xóa giao dịch: $e');
    }
  }

  void showTransactionDetails(Map<String, dynamic> item) {
    final path = item['receiptImagePath'] as String?;
    final hasImage = path != null && path.isNotEmpty && File(path).existsSync();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DFEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chi tiết giao dịch',
                style: TextStyle(
                  color: textColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item['title'] as String,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                formatMoney((item['amount'] as num).toInt()),
                style: TextStyle(
                  color: (item['amount'] as num) >= 0 ? greenColor : pinkColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              detailRow('Danh mục', item['category'] as String),
              detailRow('Ngày', item['subtitle'] as String),
              const SizedBox(height: 16),
              if (hasImage) ...[
                const Text(
                  'Ảnh hóa đơn',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(path),
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ] else
                const Text(
                  'Giao dịch này không có ảnh hóa đơn.',
                  style: TextStyle(color: secondaryText),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: secondaryText)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            buildHome(),
            buildStatistics(),
            buildTransactions(),
            buildProfile(),
          ],
        ),
      ),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: openReceiptScanner,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.document_scanner_rounded),
              label: const Text('Quét hóa đơn'),
            )
          : selectedIndex == 2
          ? FloatingActionButton(
              onPressed: addTransaction,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: lightPurple,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Thống kê',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    final categoryTotals = <String, int>{};

    for (final item in transactions) {
      final amount = (item['amount'] as num).toInt();
      if (amount >= 0) continue;

      final category = item['category'] as String? ?? 'Khác';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount.abs();
    }

    final recent = [...transactions]
      ..sort((a, b) => (b['id'] as int? ?? 0).compareTo(a['id'] as int? ?? 0));

    return RefreshIndicator(
      onRefresh: loadTransactions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFDCE9), Color(0xFFE8DFFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào bạn 👋',
                      style: TextStyle(color: secondaryText, fontSize: 13),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Quản lý chi tiêu',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showMessage('Bạn chưa có thông báo mới.'),
                icon: const Icon(Icons.notifications_none_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          Container(
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB09AE9), Color(0xFF8571CD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Số dư ước tính',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatMoney(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: moneySummary(
                        'Thu nhập',
                        totalIncome,
                        Icons.south_west_rounded,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 45,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: moneySummary(
                        'Chi tiêu',
                        totalExpense,
                        Icons.north_east_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 27),
          sectionHeading('Tổng quan', 'Từ các giao dịch đã lưu'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: smallSummaryCard(
                  title: 'Thu nhập',
                  amount: totalIncome,
                  icon: Icons.south_west_rounded,
                  color: greenColor,
                  background: const Color(0xFFEAF8F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: smallSummaryCard(
                  title: 'Chi tiêu',
                  amount: totalExpense,
                  icon: Icons.north_east_rounded,
                  color: pinkColor,
                  background: lightPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 27),
          sectionHeading(
            'Chi tiêu theo danh mục',
            'Tổng hợp từ dữ liệu thực tế',
            actionText: 'Chi tiết',
            onAction: () => setState(() => selectedIndex = 1),
          ),
          const SizedBox(height: 12),
          if (categoryTotals.isEmpty)
            emptyCard(
              icon: Icons.pie_chart_outline_rounded,
              message: 'Chưa có khoản chi tiêu để thống kê.',
            )
          else
            ...categoryTotals.entries.map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }),
          if (categoryTotals.isNotEmpty)
            ...categoryTotals.entries
                .toList()
                .toList()
                .take(0)
                .map((_) => const SizedBox.shrink()),
          if (categoryTotals.isNotEmpty) ...buildCategoryCards(categoryTotals),
          const SizedBox(height: 27),
          sectionHeading(
            'Giao dịch gần đây',
            'Những khoản thu và chi mới nhất',
            actionText: 'Xem tất cả',
            onAction: () => setState(() => selectedIndex = 2),
          ),
          const SizedBox(height: 12),
          if (isLoadingTransactions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: primaryColor),
              ),
            )
          else if (recent.isEmpty)
            emptyCard(
              icon: Icons.receipt_long_outlined,
              message:
                  'Chưa có giao dịch. Hãy thêm giao dịch hoặc quét hóa đơn.',
            )
          else
            ...recent.take(4).map(buildTransactionTile),
          const SizedBox(height: 22),
          InkWell(
            onTap: openAiExpenseAssistant,
            borderRadius: BorderRadius.circular(23),
            child: Container(
              padding: const EdgeInsets.all(19),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE7F0), Color(0xFFECE5FF)],
                ),
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 33,
                    color: primaryColor,
                  ),
                  SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trợ lý tài chính AI',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Nhận xét và gợi ý tiết kiệm cá nhân hóa.',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildCategoryCards(Map<String, int> totals) {
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((entry) {
      final color = categoryColors[entry.key] ?? categoryColors['Khác']!;
      final ratio = totalExpense == 0
          ? 0.0
          : (entry.value / totalExpense).clamp(0.0, 1.0);

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcon(entry.key), color: color, size: 20),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  formatMoney(entry.value),
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                color: color,
                backgroundColor: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget moneySummary(String label, int amount, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatMoney(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget smallSummaryCard({
    required String title,
    required int amount,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(color: secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionHeading(
    String title,
    String subtitle, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: secondaryText, fontSize: 11),
              ),
            ],
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionText,
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget emptyCard({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: primaryColor),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: secondaryText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTransactionTile(Map<String, dynamic> item) {
    final amount = (item['amount'] as num).toInt();
    final color = item['color'] as Color;
    final path = item['receiptImagePath'] as String?;
    final hasImage = path != null && path.isNotEmpty && File(path).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => showTransactionDetails(item),
              child: Row(
                children: [
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(path),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: color,
                        size: 22,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${item['category']} • ${item['subtitle']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: secondaryText,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${amount > 0 ? '+' : ''}${formatMoney(amount)}',
                          style: TextStyle(
                            color: amount > 0 ? greenColor : textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Xóa giao dịch',
            onPressed: () => deleteTransaction(item),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFD67D99),
            ),
          ),
        ],
      ),
    );
  }

  
Widget buildStatistics() {
  DateTime? parseTransactionDate(String? raw) {
    if (raw == null) return null;

    final match =
        RegExp(r'^(\d{2})/(\d{2})/(\d{4})').firstMatch(raw);

    if (match == null) return null;

    return DateTime(
      int.parse(match[3]!),
      int.parse(match[2]!),
      int.parse(match[1]!),
    );
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(
    Duration(days: today.weekday - 1),
  );

  int monthIncome = 0;
  int monthExpense = 0;
  int allExpense = 0;

  final categoryTotals = <String, int>{};
  final weekTotals = List<int>.filled(7, 0);

  for (final item in transactions) {
    final amount = (item['amount'] as num).toInt();
    final category = item['category'] as String? ?? 'Khác';
    final date = parseTransactionDate(
      item['subtitle'] as String?,
    );

    if (amount < 0) {
      allExpense += amount.abs();

      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + amount.abs();

      if (date != null &&
          date.year == now.year &&
          date.month == now.month) {
        monthExpense += amount.abs();
      }

      if (date != null &&
          !date.isBefore(weekStart) &&
          !date.isAfter(today)) {
        weekTotals[date.weekday - 1] += amount.abs();
      }
    } else if (amount > 0 &&
        date != null &&
        date.year == now.year &&
        date.month == now.month) {
      monthIncome += amount;
    }
  }

  final sortedCategories = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final maxWeekExpense = weekTotals.fold<int>(
    0,
    (maximum, value) => value > maximum ? value : maximum,
  );

  final weekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  return RefreshIndicator(
    onRefresh: loadTransactions,
    color: primaryColor,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        const Text(
          'Thống kê',
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Theo dõi chi tiêu của bạn mỗi ngày ✨',
          style: TextStyle(
            color: secondaryText,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 22),

        // TỔNG CHI TIÊU THÁNG NÀY
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFE7DDFB),
                Color(0xFFFFE5EF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: pinkColor.withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Tổng chi tiêu tháng này',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '${formatMoney(monthExpense)} đ',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatisticsMiniCard(
                      label: 'Thu nhập',
                      amount: monthIncome,
                      icon: Icons.south_west_rounded,
                      color: greenColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatisticsMiniCard(
                      label: 'Chi tiêu',
                      amount: monthExpense,
                      icon: Icons.north_east_rounded,
                      color: const Color(0xFFD96896),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        // BIỂU ĐỒ CHI TIÊU 7 NGÀY
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chi tiêu trong tuần',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '7 ngày',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF2EAF8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${formatMoney(weekTotals.fold<int>(0, (a, b) => a + b))} đ',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tổng chi tiêu từ thứ Hai đến hôm nay',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(7, (index) {
                    final value = weekTotals[index];
                    final isToday = index == now.weekday - 1;
                    final barHeight = maxWeekExpense == 0
                        ? 5.0
                        : math.max(
                            5.0,
                            value / maxWeekExpense * 95,
                          ).toDouble();

                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            value == 0
                                ? ''
                                : value >= 1000000
                                    ? '${(value / 1000000).toStringAsFixed(1)}tr'
                                    : value >= 1000
                                        ? '${(value / 1000).round()}k'
                                        : '$value',
                            style: const TextStyle(
                              color: secondaryText,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 100,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 22,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isToday
                                        ? const [
                                            Color(0xFFB8A0F5),
                                            Color(0xFF8D73D2),
                                          ]
                                        : const [
                                            Color(0xFFF5C9DC),
                                            Color(0xFFE99AB7),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            weekdayLabels[index],
                            style: TextStyle(
                              color: isToday
                                  ? primaryColor
                                  : secondaryText,
                              fontSize: 11,
                              fontWeight: isToday
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

        // BIỂU ĐỒ TRÒN THEO DANH MỤC
        const Text(
          'Phân bổ chi tiêu',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Các danh mục từ toàn bộ giao dịch đã lưu',
          style: TextStyle(
            color: secondaryText,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF2EAF8),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 175,
                      height: 175,
                      child: CustomPaint(
                        painter: _ExpenseDonutPainter(
                          totals: sortedCategories,
                          total: allExpense,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tổng chi',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          allExpense >= 1000000
                              ? '${(allExpense / 1000000).toStringAsFixed(1)}tr'
                              : allExpense >= 1000
                                  ? '${(allExpense / 1000).round()}k'
                                  : '$allExpense',
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'VNĐ',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (sortedCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Chưa có dữ liệu chi tiêu.\nHãy thêm giao dịch để xem biểu đồ nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryText,
                      height: 1.6,
                    ),
                  ),
                )
              else
                ...sortedCategories.map((entry) {
                  final color =
                      categoryColors[entry.key] ??
                      categoryColors['Khác']!;
                  final percent = allExpense == 0
                      ? 0.0
                      : entry.value / allExpense * 100;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${percent.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${formatMoney(entry.value)} đ',
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFF4EFF8),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // TÓM TẮT
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: lightPink,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                color: pinkColor,
                size: 25,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng quan tài chính',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      monthExpense == 0
                          ? 'Bạn chưa có khoản chi tiêu trong tháng này. Hãy ghi lại các khoản thu chi để theo dõi tài chính nhé!'
                          : 'Tháng này bạn đã chi ${formatMoney(monthExpense)} đ và có ${formatMoney(monthIncome)} đ thu nhập. Hãy theo dõi các danh mục chi tiêu để quản lý ngân sách tốt hơn nhé!',
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget buildTransactions() {
    final query = searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? [...transactions]
        : transactions.where((item) {
            final title = (item['title'] as String? ?? '').toLowerCase();
            final category = (item['category'] as String? ?? '').toLowerCase();
            final subtitle = (item['subtitle'] as String? ?? '').toLowerCase();
            return title.contains(query) ||
                category.contains(query) ||
                subtitle.contains(query);
          }).toList();

    filtered.sort(
      (a, b) => (b['id'] as int? ?? 0).compareTo(a['id'] as int? ?? 0),
    );

    return RefreshIndicator(
      onRefresh: loadTransactions,
      color: primaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
        children: [
          const Text(
            'Giao dịch',
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Xem và quản lý các khoản thu chi của bạn',
            style: TextStyle(color: secondaryText, fontSize: 13),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên hoặc danh mục',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(() => searchQuery = ''),
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 18),
          if (isLoadingTransactions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: primaryColor),
              ),
            )
          else if (filtered.isEmpty)
            emptyCard(
              icon: Icons.receipt_long_outlined,
              message: query.isEmpty
                  ? 'Chưa có giao dịch nào. Nhấn nút + để thêm mới.'
                  : 'Không tìm thấy giao dịch phù hợp.',
            )
          else
            ...filtered.map(buildTransactionTile),
        ],
      ),
    );
  }

  Widget buildProfile() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        const Text(
          'Cá nhân',
          style: TextStyle(
            color: textColor,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        
const SizedBox(height: 12),
Builder(
  builder: (context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        secondary: const Icon(
          Icons.dark_mode_rounded,
          color: primaryColor,
        ),
        title: const Text(
          'Chế độ tối',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: const Text('Bảo vệ mắt khi dùng ban đêm'),
        value: appThemeController.isDarkMode,
        onChanged: (enabled) {
          appThemeController.toggle(enabled);
        },
      ),
    );
  },
),

        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE2ED), Color(0xFFECE5FF)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          
child: Column(
  children: [
    CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person_rounded,
        size: 45,
        color: primaryColor,
      ),
    ),
    SizedBox(height: 13),
    Text(
  widget.user['name']?.toString() ?? 'Người dùng',
  textAlign: TextAlign.center,
  style: const TextStyle(
    color: textColor,
    fontSize: 20,
    fontWeight: FontWeight.w900,
  ),
),
  const SizedBox(height: 5),
Text(
  widget.user['email']?.toString() ?? '',
  textAlign: TextAlign.center,
  style: const TextStyle(
    color: secondaryText,
  ),
),
    SizedBox(height: 5),
    Text(
      'Quản lý tài chính cá nhân',
      style: TextStyle(color: secondaryText),
    ),
  ],
),

        ),
        const SizedBox(height: 24),
        profileTile(
          Icons.auto_awesome_rounded,
          'Trợ lý tài chính AI',
          'Nhận phân tích chi tiêu',
          openAiExpenseAssistant,
        ),
        profileTile(
          Icons.document_scanner_rounded,
          'Quét hóa đơn',
          'Nhận diện thông tin bằng OCR',
          openReceiptScanner,
        ),
        profileTile(
          Icons.savings_outlined,
          'Mục tiêu tiết kiệm',
          'Thiết lập mục tiêu của bạn',
          () => showMessage('Tính năng mục tiêu tiết kiệm sẽ được bổ sung.'),
        ),
        profileTile(
          Icons.account_balance_wallet_outlined,
          'Ngân sách',
          'Thiết lập giới hạn chi tiêu',
          () => showMessage('Tính năng ngân sách sẽ được bổ sung.'),
        ),
        profileTile(
          Icons.settings_outlined,
          'Cài đặt',
          'Tùy chỉnh ứng dụng',
          () => showMessage('Tính năng cài đặt sẽ được bổ sung.'),
        ),
        profileTile(
          Icons.info_outline_rounded,
          'Thông tin ứng dụng',
          'Receipt OCR & Expense Tracker',
          () => showAboutDialog(
            context: context,
            applicationName: 'Expense Tracker',
            applicationVersion: '1.0.0',
            applicationLegalese: 'Ứng dụng quản lý chi tiêu cá nhân.',
          ),
        ),
        profileTile(
  Icons.logout_rounded,
  'Đăng xuất',
  'Thoát khỏi tài khoản hiện tại',
  () async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onLogout();
    }
  },
),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Made with ♡',
            style: TextStyle(color: secondaryText, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget profileTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: lightPurple,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: secondaryText, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: secondaryText),
        onTap: onTap,
      ),
    );
  }
}
