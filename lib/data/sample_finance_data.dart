import 'package:flutter/material.dart';

import 'package:finance_frontend/apptheme.dart';

/// Temporary sample dashboard data until APIs are provided.
abstract final class SampleFinanceData {
  static const totalBalance = 22500.0;
  static const totalIncome = 45000.0;
  static const totalExpense = 22500.0;

  static const expenseBreakdown = <ExpenseSlice>[
    ExpenseSlice(label: 'Food', percent: 0.28, color: Color(0xFF2FE6A0)),
    ExpenseSlice(label: 'Shopping', percent: 0.22, color: Color(0xFF5CF2C0)),
    ExpenseSlice(label: 'Travel', percent: 0.16, color: Color(0xFF279D6E)),
    ExpenseSlice(label: 'Bills', percent: 0.19, color: Color(0xFF4FD1C5)),
    ExpenseSlice(label: 'Others', percent: 0.15, color: Color(0xFF7FA593)),
  ];

  static const transactions = <SampleTransaction>[
    SampleTransaction(
      title: 'Swiggy Order',
      category: 'Food',
      dateLabel: 'Today',
      amount: 420,
      isExpense: true,
      icon: Icons.restaurant_rounded,
    ),
    SampleTransaction(
      title: 'Salary Credit',
      category: 'Income',
      dateLabel: 'Yesterday',
      amount: 45000,
      isExpense: false,
      icon: Icons.account_balance_wallet_rounded,
    ),
    SampleTransaction(
      title: 'Uber Ride',
      category: 'Travel',
      dateLabel: '18 Sep',
      amount: 280,
      isExpense: true,
      icon: Icons.directions_car_rounded,
    ),
    SampleTransaction(
      title: 'Amazon Shopping',
      category: 'Shopping',
      dateLabel: '17 Sep',
      amount: 1899,
      isExpense: true,
      icon: Icons.shopping_bag_rounded,
    ),
    SampleTransaction(
      title: 'Electricity Bill',
      category: 'Bills',
      dateLabel: '15 Sep',
      amount: 1450,
      isExpense: true,
      icon: Icons.bolt_rounded,
    ),
  ];

  static const monthlyBars = <MonthlyBar>[
    MonthlyBar(month: 'May', income: 38000, expense: 21000),
    MonthlyBar(month: 'Jun', income: 40000, expense: 24000),
    MonthlyBar(month: 'Jul', income: 42000, expense: 23000),
    MonthlyBar(month: 'Aug', income: 41000, expense: 26000),
    MonthlyBar(month: 'Sep', income: 45000, expense: 22500),
  ];
}

class ExpenseSlice {
  const ExpenseSlice({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final double percent;
  final Color color;
}

class SampleTransaction {
  const SampleTransaction({
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.amount,
    required this.isExpense,
    required this.icon,
  });

  final String title;
  final String category;
  final String dateLabel;
  final double amount;
  final bool isExpense;
  final IconData icon;
}

class MonthlyBar {
  const MonthlyBar({
    required this.month,
    required this.income,
    required this.expense,
  });

  final String month;
  final double income;
  final double expense;
}

String formatInr(num value) {
  final n = value.round().abs();
  final s = n.toString();
  if (s.length <= 3) return '₹ $s';

  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '₹ ${parts.join(',')},$last3';
}

Color get incomeColor => AppColors.primary;
Color get expenseColor => AppColors.error;
