import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/app_state.dart';
import '../models/meal_entry.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  static const categories = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Cemilan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final mealsByCategory = <String, List<MealEntry>>{};
          for (final category in categories) {
            mealsByCategory[category] = [];
          }
          for (final meal in state.mealEntries) {
            mealsByCategory[meal.category] ??= [];
            mealsByCategory[meal.category]!.add(meal);
          }
          final totalCalories = state.mealEntries.fold<int>(
            0,
            (sum, meal) => sum + meal.calories * meal.quantity,
          );
          final targetCalories = 2000;
          final progress =
              targetCalories == 0 ? 0.0 : totalCalories / targetCalories;
          final protein = _macroSum(state.mealEntries, (meal) => meal.protein);
          final carbs = _macroSum(state.mealEntries, (meal) => meal.carbs);
          final fat = _macroSum(state.mealEntries, (meal) => meal.fat);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              _CaloriesPlanCard(
                totalCalories: totalCalories,
                targetCalories: targetCalories,
                progress: progress,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MacroSummaryChip(
                      label: 'Protein',
                      value: protein,
                      target: 100,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MacroSummaryChip(
                      label: 'Karbo',
                      value: carbs,
                      target: 250,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MacroSummaryChip(
                      label: 'Lemak',
                      value: fat,
                      target: 70,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rencanakan Makanan',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: () => _showMealForm(context),
                    icon: const Icon(Icons.search),
                    label: const Text('Cari Makanan'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final category in categories) ...[
                _MealCategorySection(
                  category: category,
                  meals: mealsByCategory[category] ?? [],
                  onEdit: (meal) => _showMealForm(context, existing: meal),
                  onDelete: (meal) =>
                      context.read<AppState>().deleteMealEntry(meal.id!),
                  onAdd: () =>
                      _showMealForm(context, defaultCategory: category),
                  onDetail: (meal) => _showMealDetail(context, meal),
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMealForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Makanan'),
      ),
    );
  }

  Future<void> _showMealForm(
    BuildContext context, {
    MealEntry? existing,
    String? defaultCategory,
  }) async {
    final result = await showModalBottomSheet<MealEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MealEntryForm(
          existing: existing,
          defaultCategory: defaultCategory,
        ),
      ),
    );
    if (result == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final state = context.read<AppState>();
    if (existing == null) {
      await state.addMealEntry(result);
    } else {
      await state.updateMealEntry(result);
    }
  }

  void _showMealDetail(BuildContext context, MealEntry meal) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _MealDetailSheet(meal: meal),
    );
  }

  static int _macroSum(
    List<MealEntry> entries,
    int Function(MealEntry meal) extractor,
  ) {
    return entries.fold<int>(
      0,
      (previousValue, element) =>
          previousValue + extractor(element) * element.quantity,
    );
  }
}

class _CaloriesPlanCard extends StatelessWidget {
  const _CaloriesPlanCard({
    required this.totalCalories,
    required this.targetCalories,
    required this.progress,
  });

  final int totalCalories;
  final int targetCalories;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kalori Terencana',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat('#,###').format(totalCalories),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '/$targetCalories kkal',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: clampedProgress,
                minHeight: 12,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroSummaryChip extends StatelessWidget {
  const _MacroSummaryChip({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final int value;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : value / target;
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 8,
                  value: clampedProgress,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: AppColors.border,
                ),
                Text(
                  '$value/$target',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _MealDetailSheet extends StatelessWidget {
  const _MealDetailSheet({required this.meal});

  final MealEntry meal;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final totalCalories = meal.calories * meal.quantity;
    final totalProtein = meal.protein * meal.quantity;
    final totalCarbs = meal.carbs * meal.quantity;
    final totalFat = meal.fat * meal.quantity;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detail Makanan',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              meal.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              meal.category,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MealInfoChip(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Kalori Total',
                  value: '${formatter.format(totalCalories)} kkal',
                ),
                _MealInfoChip(
                  icon: Icons.restaurant_menu_outlined,
                  label: 'Porsi',
                  value: '${meal.quantity}x',
                ),
                _MealInfoChip(
                  icon: Icons.scale_outlined,
                  label: 'Kalori/Porsi',
                  value: '${formatter.format(meal.calories)} kkal',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Makro keseluruhan',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MacroInfoTile(
                    color: AppColors.primaryGreen,
                    icon: Icons.fitness_center,
                    label: 'Protein',
                    value: '${formatter.format(totalProtein)} g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MacroInfoTile(
                    color: AppColors.accentOrange,
                    icon: Icons.grain,
                    label: 'Karbo',
                    value: '${formatter.format(totalCarbs)} g',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MacroInfoTile(
                    color: Colors.redAccent,
                    icon: Icons.water_drop_outlined,
                    label: 'Lemak',
                    value: '${formatter.format(totalFat)} g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Per porsi: ${formatter.format(meal.calories)} kkal • '
              '${meal.protein}g protein • ${meal.carbs}g karbo • ${meal.fat}g lemak',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealInfoChip extends StatelessWidget {
  const _MealInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: AppColors.primaryGreenFaint,
      avatar: Icon(
        icon,
        size: 18,
        color: AppColors.primaryGreen,
      ),
      label: Text('$label: $value'),
    );
  }
}

class _MacroInfoTile extends StatelessWidget {
  const _MacroInfoTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MealCategorySection extends StatelessWidget {
  const _MealCategorySection({
    required this.category,
    required this.meals,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    required this.onDetail,
  });

  final String category;
  final List<MealEntry> meals;
  final ValueChanged<MealEntry> onEdit;
  final ValueChanged<MealEntry> onDelete;
  final VoidCallback onAdd;
  final ValueChanged<MealEntry> onDetail;

  @override
  Widget build(BuildContext context) {
    final totalCalories =
        meals.fold<int>(0, (sum, meal) => sum + meal.calories * meal.quantity);
    return Card(
      child: ExpansionTile(
        initiallyExpanded: category == 'Sarapan',
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Row(
          children: [
            Icon(_iconForCategory(category), color: AppColors.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '$totalCalories kkal',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        children: [
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Belum ada menu.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...meals.map(
              (meal) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryGreenFaint,
                  child: const Icon(Icons.restaurant),
                ),
                title: Text(
                  meal.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  '${meal.quantity} porsi • ${meal.calories} kkal',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () => onDetail(meal),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => onEdit(meal),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      onPressed: () => onDelete(meal),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah dari Favorit'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Sarapan':
        return Icons.free_breakfast_outlined;
      case 'Makan Siang':
        return Icons.lunch_dining_outlined;
      case 'Makan Malam':
        return Icons.dinner_dining_outlined;
      case 'Cemilan':
        return Icons.icecream_outlined;
      default:
        return Icons.restaurant_menu_outlined;
    }
  }
}

class MealEntryForm extends StatefulWidget {
  const MealEntryForm({super.key, this.existing, this.defaultCategory});

  final MealEntry? existing;
  final String? defaultCategory;

  @override
  State<MealEntryForm> createState() => _MealEntryFormState();
}

class _MealEntryFormState extends State<MealEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _calorieController;
  late TextEditingController _quantityController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late String _category;

  @override
  void initState() {
    super.initState();
    final meal = widget.existing;
    _nameController = TextEditingController(text: meal?.name ?? '');
    _calorieController = TextEditingController(
      text: meal?.calories.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: meal?.quantity.toString() ?? '1',
    );
    _proteinController = TextEditingController(
      text: meal?.protein.toString() ?? '',
    );
    _carbsController = TextEditingController(
      text: meal?.carbs.toString() ?? '',
    );
    _fatController = TextEditingController(
      text: meal?.fat.toString() ?? '',
    );
    _category =
        meal?.category ?? widget.defaultCategory ?? MealsScreen.categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    _quantityController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final entry = MealEntry(
      id: widget.existing?.id,
      name: _nameController.text.trim(),
      category: _category,
      calories: int.parse(_calorieController.text.trim()),
      quantity: int.parse(_quantityController.text.trim()),
      protein: int.parse(_proteinController.text.trim()),
      carbs: int.parse(_carbsController.text.trim()),
      fat: int.parse(_fatController.text.trim()),
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existing == null
                      ? 'Tambah Makanan'
                      : 'Ubah Makanan',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _category,
                    items: MealsScreen.categories
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Menu',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _calorieController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Kalori (kkal)',
                          ),
                          validator: _numberValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Porsi',
                          ),
                          validator: _numberValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Protein (g)',
                          ),
                          validator: _numberValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Karbo (g)',
                          ),
                          validator: _numberValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Lemak (g)',
                          ),
                          validator: _numberValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: widget.existing == null ? 'Simpan' : 'Perbarui',
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Harus berupa angka';
    }
    return null;
  }
}
