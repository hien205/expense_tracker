
import 'package:flutter/material.dart';
import '../services/ai_expense_service.dart';

const Color _pink = Color(0xFFE99AB7);
const Color _pinkLight = Color(0xFFFFF0F5);
const Color _lavender = Color(0xFF9B8AE6);
const Color _lavenderLight = Color(0xFFF1EDFF);
const Color _ink = Color(0xFF393047);
const Color _muted = Color(0xFF898197);
const Color _surface = Color(0xFFFFFFFF);
const Color _page = Color(0xFFFFF8FB);

class AiExpenseScreen extends StatefulWidget {
  const AiExpenseScreen({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactions,
  });

  final int totalIncome;
  final int totalExpense;
  final List<Map<String, dynamic>> transactions;

  @override
  State<AiExpenseScreen> createState() => _AiExpenseScreenState();
}

class _AiExpenseScreenState extends State<AiExpenseScreen> {
  bool isLoading = false;
  String? result;
  String? error;

  int get balance => widget.totalIncome - widget.totalExpense.abs();

  String formatMoney(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()} đ';
  }

  Future<void> analyze() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      error = null;
      result = null;
    });

    try {
      final analysis = await AiExpenseService().analyzeExpenses(
        totalIncome: widget.totalIncome,
        totalExpense: widget.totalExpense,
        transactions: widget.transactions,
      );

      if (!mounted) return;

      setState(() {
        result = analysis;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beauty of Finance',
              style: TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'TRỢ LÝ TÀI CHÍNH AI',
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _buildHero(),
          const SizedBox(height: 22),
          const Text(
            'Tổng quan tài chính',
            style: TextStyle(
              color: _ink,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMoneyCard(
                  title: 'Thu nhập',
                  amount: widget.totalIncome,
                  icon: Icons.south_west_rounded,
                  color: const Color(0xFF8B79D9),
                  background: _lavenderLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMoneyCard(
                  title: 'Chi tiêu',
                  amount: widget.totalExpense.abs(),
                  icon: Icons.north_east_rounded,
                  color: const Color(0xFFD96E99),
                  background: _pinkLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBalanceCard(),
          const SizedBox(height: 24),
          _buildAnalyzeButton(),
          if (isLoading) ...[
            const SizedBox(height: 20),
            _buildLoadingCard(),
          ],
          if (error != null) ...[
            const SizedBox(height: 18),
            _buildErrorCard(),
          ],
          if (result != null) ...[
            const SizedBox(height: 24),
            _buildResultHeader(),
            const SizedBox(height: 12),
            _buildAnalysisContent(result!),
          ],
          const SizedBox(height: 24),
          _buildPrivacyNote(),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFDCE9),
            Color(0xFFE7DEFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xAAFFFFFF),
              size: 76,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF9277D8),
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'AI FINANCIAL ASSISTANT',
                      style: TextStyle(
                        color: Color(0xFF765EAA),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Chi tiêu thông minh,\ncuộc sống nhẹ nhàng.',
                style: TextStyle(
                  color: _ink,
                  fontSize: 24,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Để AI giúp bạn hiểu thói quen chi tiêu '
                'và tìm cách tiết kiệm phù hợp.',
                style: TextStyle(
                  color: Color(0xFF655A78),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyCard({
    required String title,
    required int amount,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D7199).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
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

  Widget _buildBalanceCard() {
    final positive = balance >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0E7F5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: positive ? _lavenderLight : _pinkLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: positive ? _lavender : _pink,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Số dư ước tính',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(balance),
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            positive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: positive ? _lavender : _pink,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_pink, _lavender],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _lavender.withValues(alpha: 0.22),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : analyze,
          icon: Icon(
            isLoading
                ? Icons.hourglass_top_rounded
                : Icons.auto_awesome_rounded,
            color: Colors.white,
          ),
          label: Text(
            isLoading ? 'AI đang phân tích...' : 'Phân tích chi tiêu của tôi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: _lavender,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Đang xem xét thói quen chi tiêu...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Vui lòng chờ một chút nhé.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD5DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Color(0xFFD65D79)),
              SizedBox(width: 8),
              Text(
                'Chưa thể phân tích',
                style: TextStyle(
                  color: Color(0xFFB94D6B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            error ?? '',
            style: const TextStyle(
              color: _ink,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: isLoading ? null : analyze,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    return const Row(
      children: [
        Icon(Icons.auto_awesome_rounded, color: _lavender, size: 24),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'Gợi ý dành riêng cho bạn',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisContent(String text) {
    final sections = _splitAnalysis(text);

    if (sections.length <= 1) {
      return _analysisCard(
        title: 'Phân tích từ AI',
        icon: Icons.auto_awesome_rounded,
        color: _lavender,
        background: _lavenderLight,
        content: text.trim(),
      );
    }

    final icons = <IconData>[
      Icons.insights_rounded,
      Icons.pie_chart_rounded,
      Icons.receipt_long_rounded,
      Icons.savings_rounded,
      Icons.flag_rounded,
      Icons.lightbulb_rounded,
    ];

    final colors = <Color>[
      _lavender,
      _pink,
      const Color(0xFF8D80D7),
      const Color(0xFFD77FA6),
    ];

    return Column(
      children: List.generate(sections.length, (index) {
        final section = sections[index];
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _analysisCard(
            title: section.$1,
            icon: icons[index % icons.length],
            color: color,
            background: index.isEven ? _lavenderLight : _pinkLight,
            content: section.$2,
          ),
        );
      }),
    );
  }

  List<(String, String)> _splitAnalysis(String text) {
    final lines = text.trim().split('\n');
    final sections = <(String, String)>[];
    final current = <String>[];
    String? heading;

    final headingPattern = RegExp(
      r'^\s*(?:#{1,4}\s*)?(?:(?:\d+[.)、]\s*)|(?:[-*]\s*))'
      r'(.{2,90})\s*$',
    );

    bool looksLikeHeading(String line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.length > 90) return false;

      final match = headingPattern.firstMatch(trimmed);
      if (match != null) return true;

      return trimmed.startsWith('**') &&
          trimmed.endsWith('**') &&
          trimmed.length < 85;
    }

    void saveSection() {
      final body = current.join('\n').trim();
      if (heading != null && (heading!.isNotEmpty || body.isNotEmpty)) {
        sections.add((heading!, body));
      }
      current.clear();
    }

    for (final line in lines) {
      if (looksLikeHeading(line)) {
        saveSection();

        final trimmed = line.trim();
        final match = headingPattern.firstMatch(trimmed);
        heading = match != null
            ? match.group(1)!.replaceAll('**', '').trim()
            : trimmed.replaceAll('#', '').replaceAll('*', '').trim();
      } else {
        current.add(line);
      }
    }

    saveSection();

    if (sections.isEmpty) {
      return [('Phân tích từ AI', text.trim())];
    }

    return sections;
  }

  Widget _analysisCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color background,
    required String content,
  }) {
    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0E8F4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D7199).withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (lines.isNotEmpty) ...[
            const SizedBox(height: 15),
            ...lines.map((line) {
              final cleaned = line.replaceFirst(
                RegExp(r'^(?:[-*•]|\d+[.)])\s*'),
                '',
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cleaned,
                        style: const TextStyle(
                          color: Color(0xFF61596E),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_rounded,
            color: _lavender,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Gợi ý của AI chỉ mang tính tham khảo. '
              'Hãy kiểm tra lại số liệu trước khi đưa ra quyết định tài chính.',
              style: TextStyle(
                color: Color(0xFF756B88),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
