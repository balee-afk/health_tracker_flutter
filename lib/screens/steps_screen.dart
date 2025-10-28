import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/app_state.dart';
import '../models/step_log.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class StepsScreen extends StatelessWidget {
  const StepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final stepLogs = state.stepLogs;
          if (stepLogs.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemBuilder: (context, index) {
              final log = stepLogs[index];
              final dateLabel =
                  DateFormat('EEEE, d MMMM', 'id_ID').format(log.date);
              final rawProgress =
                  log.goal == 0 ? 0.0 : log.steps / log.goal;
              final progress = rawProgress.clamp(0.0, 1.0).toDouble();
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  title: Text(
                    dateLabel,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        '${NumberFormat('#,###').format(log.steps)} langkah',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% dari target ${log.goal}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  onTap: () => _showDetail(context, log),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showStepForm(context, existing: log);
                      } else if (value == 'delete') {
                        context.read<AppState>().deleteStepLog(log.id!);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Ubah'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus'),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: stepLogs.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStepForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Catat Langkah'),
      ),
    );
  }

  Future<void> _showStepForm(BuildContext context, {StepLog? existing}) async {
    final result = await showModalBottomSheet<StepLog>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StepLogForm(existing: existing),
        );
      },
    );
    if (result == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final appState = context.read<AppState>();
    if (existing == null) {
      await appState.addStepLog(result);
    } else {
      await appState.updateStepLog(result);
    }
  }

  void _showDetail(BuildContext context, StepLog log) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _StepDetailSheet(log: log),
    );
  }
}

class _StepDetailSheet extends StatelessWidget {
  const _StepDetailSheet({required this.log});

  final StepLog log;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(log.date);
    final formatter = NumberFormat('#,###');
    final stepsText = formatter.format(log.steps);
    final goalText = formatter.format(log.goal);
    final goal = log.goal;
    final progress =
        goal <= 0 ? 0.0 : (log.steps / goal).clamp(0.0, 1.0).toDouble();
    final diff = goal <= 0 ? 0 : log.steps - goal;
    final insight = goal <= 0
        ? 'Belum ada target langkah ditetapkan.'
        : diff >= 0
            ? 'Target tercapai! Surplus ${formatter.format(diff)} langkah.'
            : 'Tambah ${formatter.format(diff.abs())} langkah lagi untuk capai target.';
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
              'Detail Langkah',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Chip(
                  avatar: const Icon(
                    Icons.directions_walk,
                    size: 18,
                    color: AppColors.primaryGreen,
                  ),
                  label: Text('Langkah: $stepsText'),
                  backgroundColor: AppColors.primaryGreenFaint,
                ),
                Chip(
                  avatar: const Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: AppColors.accentOrange,
                  ),
                  label: Text('Target: $goalText'),
                  backgroundColor: AppColors.accentOrange.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accentOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% dari target',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              insight,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_walk,
              size: 72,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada catatan langkah.',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan langkah harian Anda untuk melihat progres.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class StepLogForm extends StatefulWidget {
  const StepLogForm({super.key, this.existing});

  final StepLog? existing;

  @override
  State<StepLogForm> createState() => _StepLogFormState();
}

class _StepLogFormState extends State<StepLogForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _stepController;
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.existing?.date ?? DateTime.now();
    _stepController = TextEditingController(
      text: widget.existing?.steps.toString() ?? '',
    );
    _goalController = TextEditingController(
      text: widget.existing?.goal.toString() ?? '10000',
    );
  }

  @override
  void dispose() {
    _stepController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal',
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final steps = int.parse(_stepController.text.trim());
    final goal = int.parse(_goalController.text.trim());
    final log = StepLog(
      id: widget.existing?.id,
      date: _selectedDate,
      steps: steps,
      goal: goal,
    );
    Navigator.of(context).pop(log);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMMM yyyy', 'id_ID').format(_selectedDate);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existing == null
                      ? 'Catatan Langkah Baru'
                      : 'Ubah Catatan Langkah',
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
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tanggal'),
                    subtitle: Text(dateLabel),
                    trailing: IconButton(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _stepController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Langkah',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus berupa angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Langkah',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus berupa angka';
                      }
                      return null;
                    },
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
}
