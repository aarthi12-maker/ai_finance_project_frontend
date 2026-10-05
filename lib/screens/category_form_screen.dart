import 'package:flutter/material.dart';

import 'package:finance_frontend/apptheme.dart';
import 'package:finance_frontend/models/category_models.dart';
import 'package:finance_frontend/services/category_service.dart';
import 'package:finance_frontend/utils/category_icons.dart';

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({
    super.key,
    this.category,
    this.categoryService,
  });

  final Category? category;
  final CategoryService? categoryService;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late final CategoryService _service;
  late CategoryType _type;
  late String _icon;
  bool _loading = false;
  bool _loadingDetail = false;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _service = widget.categoryService ?? CategoryService();
    final existing = widget.category;
    _nameController.text = existing?.categoryName ?? '';
    _type = CategoryType.fromApi(existing?.categoryType);
    _icon = existing?.icon ?? 'restaurant';

    if (_isEdit) {
      _loadDetail(existing!.categoryId);
    }
  }

  Future<void> _loadDetail(int categoryId) async {
    setState(() => _loadingDetail = true);
    final result = await _service.getCategory(categoryId);
    if (!mounted) return;
    setState(() => _loadingDetail = false);

    if (result.status && result.data != null) {
      final data = result.data!;
      setState(() {
        _nameController.text = data.categoryName;
        _type = CategoryType.fromApi(data.categoryType);
        _icon = data.icon;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = CategoryRequest(
      categoryName: _nameController.text,
      categoryType: _type.apiValue,
      icon: _icon,
    );

    setState(() => _loading = true);

    final result = _isEdit
        ? await _service.updateCategory(
            categoryId: widget.category!.categoryId,
            request: request,
          )
        : await _service.createCategory(request);

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.message.isEmpty
              ? (_isEdit ? 'Category updated' : 'Category created')
              : result.message,
        ),
      ),
    );

    if (result.status) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit category' : 'New category'),
      ),
      body: _loadingDetail
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            labelText: 'Category name',
                            prefixIcon: Icon(Icons.label_outline_rounded),
                          ),
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.isEmpty) return 'Name is required';
                            if (name.length < 2) return 'Enter a valid name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Type',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<CategoryType>(
                          segments: const [
                            ButtonSegment(
                              value: CategoryType.expense,
                              label: Text('Expense'),
                              icon: Icon(Icons.south_west_rounded),
                            ),
                            ButtonSegment(
                              value: CategoryType.income,
                              label: Text('Income'),
                              icon: Icon(Icons.north_east_rounded),
                            ),
                          ],
                          selected: {_type},
                          onSelectionChanged: (values) {
                            setState(() => _type = values.first);
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Icon',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: CategoryIcons.options.entries.map((entry) {
                            final selected = entry.key == _icon;
                            return InkWell(
                              onTap: () => setState(() => _icon = entry.key),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary.withValues(alpha: 0.18)
                                      : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.outline,
                                    width: selected ? 1.5 : 1,
                                  ),
                                ),
                                child: Icon(
                                  entry.value,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.muted,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppColors.onPrimary,
                                    ),
                                  )
                                : Text(_isEdit ? 'Save changes' : 'Create category'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
