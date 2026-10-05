import 'package:flutter/material.dart';

import 'package:finance_frontend/apptheme.dart';
import 'package:finance_frontend/data/sample_finance_data.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.muted,
          tabs: const [
            Tab(text: 'Monthly'),
            Tab(text: 'Categories'),
            Tab(text: 'Trends'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _MonthlyTab(),
          _CategoriesTab(),
          const Center(
            child: Text('Trends coming soon (sample)'),
          ),
        ],
      ),
    );
  }
}

class _MonthlyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Income',
                value: formatInr(SampleFinanceData.totalIncome),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Expense',
                value: formatInr(SampleFinanceData.totalExpense),
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Savings',
                value: formatInr(
                  SampleFinanceData.totalIncome - SampleFinanceData.totalExpense,
                ),
                color: AppColors.primarySoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Income vs Expense',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: CustomPaint(
            painter: IncomeExpenseBarPainter(
              bars: SampleFinanceData.monthlyBars,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _LegendDot(color: AppColors.primary, label: 'Income'),
            SizedBox(width: 16),
            _LegendDot(color: AppColors.error, label: 'Expense'),
          ],
        ),
      ],
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: SampleFinanceData.expenseBreakdown.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final slice = SampleFinanceData.expenseBreakdown[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 8,
                backgroundColor: slice.color,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(slice.label)),
              Text(
                '${(slice.percent * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class IncomeExpenseBarPainter extends CustomPainter {
  IncomeExpenseBarPainter({required this.bars});

  final List<MonthlyBar> bars;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    final maxValue = bars
        .expand((b) => [b.income, b.expense])
        .reduce((a, b) => a > b ? a : b);
    final groupWidth = size.width / bars.length;
    final barWidth = groupWidth * 0.28;
    final chartHeight = size.height - 24;

    final incomePaint = Paint()..color = AppColors.primary;
    final expensePaint = Paint()..color = AppColors.error;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final xCenter = groupWidth * i + groupWidth / 2;
      final incomeH = (bar.income / maxValue) * chartHeight;
      final expenseH = (bar.expense / maxValue) * chartHeight;

      final incomeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          xCenter - barWidth - 3,
          chartHeight - incomeH,
          barWidth,
          incomeH,
        ),
        const Radius.circular(4),
      );
      final expenseRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          xCenter + 3,
          chartHeight - expenseH,
          barWidth,
          expenseH,
        ),
        const Radius.circular(4),
      );

      canvas.drawRRect(incomeRect, incomePaint);
      canvas.drawRRect(expenseRect, expensePaint);

      textPainter.text = TextSpan(
        text: bar.month,
        style: const TextStyle(color: AppColors.muted, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xCenter - textPainter.width / 2, size.height - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant IncomeExpenseBarPainter oldDelegate) {
    return oldDelegate.bars != bars;
  }
}
