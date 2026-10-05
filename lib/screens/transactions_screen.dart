import 'package:flutter/material.dart';

import 'package:finance_frontend/apptheme.dart';
import 'package:finance_frontend/data/sample_finance_data.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'All';

  List<SampleTransaction> get _items {
    final all = SampleFinanceData.transactions;
    if (_filter == 'Income') {
      return all.where((t) => !t.isExpense).toList();
    }
    if (_filter == 'Expense') {
      return all.where((t) => t.isExpense).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: ['All', 'Income', 'Expense'].map((label) {
                final selected = _filter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = label),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.outline,
                    ),
                    backgroundColor: AppColors.surface,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index];
                final amountColor =
                    item.isExpense ? AppColors.error : AppColors.primary;
                final prefix = item.isExpense ? '-' : '+';
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: amountColor.withValues(alpha: 0.15),
                      foregroundColor: amountColor,
                      child: Icon(item.icon, size: 20),
                    ),
                    title: Text(item.title),
                    subtitle: Text('${item.category} • ${item.dateLabel}'),
                    trailing: Text(
                      '$prefix${formatInr(item.amount)}',
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
