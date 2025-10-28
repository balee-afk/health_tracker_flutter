import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/app_state.dart';
import '../models/sleep_log.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final logs = state.sleepLogs;
          if (logs.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final dateLabel =
                  DateFormat('EEEE, d MMMM', 'id_ID').format(log.date);
              final duration = _formatDuration(log.durationMinutes);
              final timeRange = _formatTimeRange(log);
              final insight = _durationInsight(log.durationMinutes);
              final notes = log.notes;
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEBFB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      color: Color(0xFF6D28D9),
                    ),
                  ),
                  title: Text(
                    dateLabel,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$duration • Kualitas: ${log.quality}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (timeRange != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Jam tidur: $timeRange',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            insight,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        if (notes != null && notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Catatan: $notes',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () => _showDetails(context, log),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showForm(context, existing: log);
                      } else if (value == 'delete') {
                        context.read<AppState>().deleteSleepLog(log.id!);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Ubah'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Hapus'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Catat Tidur'),
      ),
    );
  }

  void _showDetails(BuildContext context, SleepLog log) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SleepDetailSheet(log: log),
    );
  }

  static String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return '${hours}j ${remaining}m';
  }

  static String? _formatTimeRange(SleepLog log) {
    final start = log.sleepStart;
    final end = log.sleepEnd;
    if (start == null || end == null) {
      return null;
    }
    final formatter = DateFormat('HH.mm', 'id_ID');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  static String _durationInsight(int minutes) {
    const targetMinutes = 480;
    final diff = minutes - targetMinutes;
    if (diff.abs() <= 30) {
      return 'Durasi mendekati target tidur 8 jam';
    }
    final absDiff = diff.abs();
    final hours = absDiff ~/ 60;
    final remaining = absDiff % 60;
    final parts = <String>[];
    if (hours > 0) {
      parts.add('${hours}j');
    }
    if (remaining > 0) {
      parts.add('${remaining}m');
    }
    final formatted = parts.join(' ');
    if (diff > 0) {
      return 'Melebihi target tidur $formatted';
    }
    return 'Kurang dari target tidur $formatted';
  }

  Future<void> _showForm(BuildContext context, {SleepLog? existing}) async {
    final result = await showModalBottomSheet<SleepLog>(
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
        child: SleepLogForm(existing: existing),
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
      await state.addSleepLog(result);
    } else {
      await state.updateSleepLog(result);
    }
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
              Icons.nightlight_round,
              size: 72,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada catatan tidur.',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Simpan durasi tidur untuk memantau kualitas istirahat Anda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepDetailSheet extends StatelessWidget {
  const _SleepDetailSheet({required this.log});

  final SleepLog log;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(log.date);
    final duration = SleepScreen._formatDuration(log.durationMinutes);
    final range = SleepScreen._formatTimeRange(log);
    final insight = SleepScreen._durationInsight(log.durationMinutes);
    final notes = log.notes;
    final start = log.sleepStart;
    final end = log.sleepEnd;
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
              'Detail Tidur',
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
                _InfoChip(
                  icon: Icons.schedule_outlined,
                  label: 'Durasi',
                  value: duration,
                ),
                _InfoChip(
                  icon: Icons.star_rate_rounded,
                  label: 'Kualitas',
                  value: log.quality,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              insight,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            if (range != null || start != null || end != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rentang Waktu',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (range != null)
                      Text(
                        range,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (start != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _DetailRow(
                          icon: Icons.bedtime_outlined,
                          label: 'Tidur',
                          value:
                              DateFormat('HH.mm', 'id_ID').format(start),
                        ),
                      ),
                    if (end != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _DetailRow(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Bangun',
                          value: DateFormat('HH.mm', 'id_ID').format(end),
                        ),
                      ),
                  ],
                ),
              ),
            if (notes != null && notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notes,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
      avatar: Icon(
        icon,
        size: 18,
        color: AppColors.primaryGreen,
      ),
      label: Text('$label: $value'),
      backgroundColor: AppColors.primaryGreenFaint,
    );
  }
}

class SleepLogForm extends StatefulWidget {
  const SleepLogForm({super.key, this.existing});

  final SleepLog? existing;

  @override
  State<SleepLogForm> createState() => _SleepLogFormState();
}

class _SleepLogFormState extends State<SleepLogForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TextEditingController _durationController;
  late TextEditingController _notesController;
  TimeOfDay? _sleepStart;
  TimeOfDay? _sleepEnd;
  String _quality = 'Baik';

  final qualities = const ['Sangat Baik', 'Baik', 'Cukup', 'Kurang'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.existing?.date ?? DateTime.now();
    _durationController = TextEditingController(
      text: widget.existing?.durationMinutes.toString() ?? '420',
    );
    _quality = widget.existing?.quality ?? 'Baik';
    _notesController = TextEditingController(
      text: widget.existing?.notes ?? '',
    );
    final start = widget.existing?.sleepStart;
    final end = widget.existing?.sleepEnd;
    if (start != null) {
      _sleepStart = TimeOfDay.fromDateTime(start);
    }
    if (end != null) {
      _sleepEnd = TimeOfDay.fromDateTime(end);
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _syncDurationWithRange();
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime = isStart
        ? _sleepStart ?? const TimeOfDay(hour: 22, minute: 0)
        : _sleepEnd ?? const TimeOfDay(hour: 6, minute: 30);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _sleepStart = picked;
        } else {
          _sleepEnd = picked;
        }
        _syncDurationWithRange();
      });
    }
  }

  void _syncDurationWithRange() {
    if (_sleepStart == null || _sleepEnd == null) {
      return;
    }
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _sleepStart!.hour,
      _sleepStart!.minute,
    );
    var end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _sleepEnd!.hour,
      _sleepEnd!.minute,
    );
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    final minutes = end.difference(start).inMinutes;
    if (minutes > 0) {
      _durationController.text = minutes.toString();
    }
  }

  String _timeLabel(TimeOfDay? time) {
    if (time == null) {
      return '-';
    }
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
    return DateFormat('HH.mm', 'id_ID').format(dateTime);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final durationText = _durationController.text.trim();
    final parsedDuration = int.parse(durationText);
    DateTime? sleepStart;
    if (_sleepStart != null) {
      sleepStart = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _sleepStart!.hour,
        _sleepStart!.minute,
      );
    }
    DateTime? sleepEnd;
    if (_sleepEnd != null) {
      sleepEnd = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _sleepEnd!.hour,
        _sleepEnd!.minute,
      );
      if (sleepStart != null && sleepEnd.isBefore(sleepStart)) {
        sleepEnd = sleepEnd.add(const Duration(days: 1));
      }
    }
    var finalDuration = parsedDuration;
    if (sleepStart != null &&
        sleepEnd != null &&
        sleepEnd.isAfter(sleepStart)) {
      finalDuration = sleepEnd.difference(sleepStart).inMinutes;
    }
    final noteText = _notesController.text.trim();
    final log = SleepLog(
      id: widget.existing?.id,
      date: _selectedDate,
      durationMinutes: finalDuration,
      quality: _quality,
      sleepStart: sleepStart,
      sleepEnd: sleepEnd,
      notes: noteText.isEmpty ? null : noteText,
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existing == null
                      ? 'Catatan Tidur Baru'
                      : 'Ubah Catatan Tidur',
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
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Durasi (menit)',
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
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Jam Tidur'),
                    subtitle: Text(_timeLabel(_sleepStart)),
                    trailing: IconButton(
                      onPressed: () => _pickTime(isStart: true),
                      icon: const Icon(Icons.bedtime_outlined),
                    ),
                    onTap: () => _pickTime(isStart: true),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Jam Bangun'),
                    subtitle: Text(_timeLabel(_sleepEnd)),
                    trailing: IconButton(
                      onPressed: () => _pickTime(isStart: false),
                      icon: const Icon(Icons.wb_sunny_outlined),
                    ),
                    onTap: () => _pickTime(isStart: false),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Durasi akan menyesuaikan otomatis jika jam tidur & bangun diisi.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _quality,
                    items: qualities
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Kualitas Tidur',
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _quality = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                    ),
                    maxLines: 3,
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
