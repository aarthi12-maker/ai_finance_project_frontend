/// Category type values expected by the backend.
enum CategoryType {
  expense('EXPENSE'),
  income('INCOME');

  const CategoryType(this.apiValue);
  final String apiValue;

  static CategoryType fromApi(String? value) {
    final normalized = (value ?? '').toUpperCase();
    return CategoryType.values.firstWhere(
      (type) => type.apiValue == normalized,
      orElse: () => CategoryType.expense,
    );
  }
}

class Category {
  const Category({
    required this.categoryId,
    required this.userId,
    required this.categoryName,
    required this.categoryType,
    required this.icon,
    required this.status,
    this.createdOn,
    this.updatedOn,
  });

  final int categoryId;
  final int userId;
  final String categoryName;
  final String categoryType;
  final String icon;
  final int status;
  final DateTime? createdOn;
  final DateTime? updatedOn;

  bool get isActive => status == 1;
  bool get isExpense => categoryType.toUpperCase() == 'EXPENSE';
  bool get isIncome => categoryType.toUpperCase() == 'INCOME';

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: _asInt(json['category_id']),
      userId: _asInt(json['user_id']),
      categoryName: json['category_name'] as String? ?? '',
      categoryType: json['category_type'] as String? ?? 'EXPENSE',
      icon: json['icon'] as String? ?? 'category',
      status: _asInt(json['status']),
      createdOn: _asDate(json['created_on']),
      updatedOn: _asDate(json['updated_on']),
    );
  }

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'user_id': userId,
        'category_name': categoryName,
        'category_type': categoryType,
        'icon': icon,
        'status': status,
        'created_on': createdOn?.toIso8601String(),
        'updated_on': updatedOn?.toIso8601String(),
      };

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static DateTime? _asDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class CategoryRequest {
  const CategoryRequest({
    required this.categoryName,
    required this.categoryType,
    required this.icon,
  });

  final String categoryName;
  final String categoryType;
  final String icon;

  Map<String, dynamic> toJson() => {
        'category_name': categoryName.trim(),
        'category_type': categoryType,
        'icon': icon,
      };
}

class CategoryListResponse {
  const CategoryListResponse({
    required this.status,
    required this.message,
    this.data = const [],
  });

  final bool status;
  final String message;
  final List<Category> data;

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <Category>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          list.add(Category.fromJson(item));
        }
      }
    }
    return CategoryListResponse(
      status: json['status'] == true,
      message: json['message'] as String? ?? '',
      data: list,
    );
  }
}

class CategoryDetailResponse {
  const CategoryDetailResponse({
    required this.status,
    required this.message,
    this.data,
  });

  final bool status;
  final String message;
  final Category? data;

  factory CategoryDetailResponse.fromJson(Map<String, dynamic> json) {
    return CategoryDetailResponse(
      status: json['status'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? Category.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CategoryMutationResponse {
  const CategoryMutationResponse({
    required this.status,
    required this.message,
    this.categoryId,
  });

  final bool status;
  final String message;
  final int? categoryId;

  factory CategoryMutationResponse.fromJson(Map<String, dynamic> json) {
    int? id;
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final raw = data['category_id'];
      if (raw is int) {
        id = raw;
      } else if (raw is num) {
        id = raw.toInt();
      } else {
        id = int.tryParse('$raw');
      }
    }
    return CategoryMutationResponse(
      status: json['status'] == true,
      message: json['message'] as String? ?? '',
      categoryId: id,
    );
  }
}
