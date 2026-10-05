import 'package:flutter/material.dart';

import 'package:finance_frontend/apptheme.dart';

/// Maps backend icon names to Material icons.
abstract final class CategoryIcons {
  static const options = <String, IconData>{
    'restaurant': Icons.restaurant_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'local_grocery_store': Icons.local_grocery_store_rounded,
    'directions_car': Icons.directions_car_rounded,
    'flight': Icons.flight_rounded,
    'home': Icons.home_rounded,
    'bolt': Icons.bolt_rounded,
    'medical_services': Icons.medical_services_rounded,
    'school': Icons.school_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'movie': Icons.movie_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'work': Icons.work_rounded,
    'savings': Icons.savings_rounded,
    'account_balance': Icons.account_balance_rounded,
    'payments': Icons.payments_rounded,
    'card_giftcard': Icons.card_giftcard_rounded,
    'pets': Icons.pets_rounded,
    'coffee': Icons.coffee_rounded,
    'phone_iphone': Icons.phone_iphone_rounded,
    'category': Icons.category_rounded,
  };

  static IconData resolve(String? name) {
    final key = (name ?? '').trim();
    return options[key] ?? Icons.category_rounded;
  }

  static Widget avatar(String? name, {bool expense = true}) {
    return CircleAvatar(
      backgroundColor: expense
          ? AppColors.primary.withValues(alpha: 0.15)
          : AppColors.primarySoft.withValues(alpha: 0.18),
      foregroundColor: expense ? AppColors.primary : AppColors.primarySoft,
      child: Icon(resolve(name), size: 22),
    );
  }
}
