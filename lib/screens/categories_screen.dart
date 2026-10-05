import 'package:flutter/material.dart';

import 'package:finance_frontend/apptheme.dart';
import 'package:finance_frontend/models/category_models.dart';
import 'package:finance_frontend/screens/category_form_screen.dart';
import 'package:finance_frontend/services/category_service.dart';
import 'package:finance_frontend/utils/category_icons.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.categoryService});

  final CategoryService? categoryService;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoryService _service;

  List<Category> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.categoryService ?? CategoryService();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getCategories();
    if (!mounted) return;

    if (result.status) {
      setState(() {
        _categories = result.data;
        _loading = false;
      });
      return;
    }

    setState(() {
      _error = result.message.isEmpty
          ? 'Failed to load categories'
          : result.message;
      _loading = false;
    });
  }

  Future<void> _openForm({Category? category}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(
          category: category,
          categoryService: _service,
        ),
      ),
    );
    if (changed == true && mounted) {
      await _loadCategories();
    }
  }

  Future<void> _confirmDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete category'),
        content: Text(
          'Delete "${category.categoryName}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await _service.deleteCategory(category.categoryId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message.isEmpty
              ? (result.status ? 'Category deleted' : 'Delete failed')
              : result.message,
        ),
      ),
    );

    if (result.status) {
      await _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadCategories,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadCategories,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (_categories.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(
            Icons.category_outlined,
            size: 56,
            color: AppColors.muted,
          ),
          const SizedBox(height: 16),
          Text(
            'No categories yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first expense or income category.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _CategoryTile(
          category: category,
          onEdit: () => _openForm(category: category),
          onDelete: () => _confirmDelete(category),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CategoryIcons.avatar(
          category.icon,
          expense: category.isExpense,
        ),
        title: Text(
          category.categoryName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          category.categoryType,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: category.isExpense
                    ? AppColors.primary
                    : AppColors.primarySoft,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.surfaceElevated,
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
