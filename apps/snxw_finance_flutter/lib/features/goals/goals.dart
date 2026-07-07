import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database_provider.dart';
import '../../core/repositories/financial_goal_repository.dart';
import '../../shared/design/design.dart';
import '../../shared/models/models.dart';

final FutureProvider<List<FinancialGoal>> goalsProvider = FutureProvider<List<FinancialGoal>>(
  (ref) async {
    final repository = FinancialGoalRepository(await ref.watch(isarProvider.future));
    return repository.list();
  },
);

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FinancialGoal>> goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text("Metas Financieras"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddGoalSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Nueva Meta"),
      ),
      body: SafeArea(
        child: goalsAsync.when(
          data: (List<FinancialGoal> goals) => _GoalList(
            goals: goals,
            onAddPressed: () => _openAddGoalSheet(context, ref),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => _GoalErrorState(
            error: error,
            onRetry: () => ref.invalidate(goalsProvider),
          ),
        ),
      ),
    );
  }

  void _openAddGoalSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return _AddGoalSheet(
          onSaved: () => ref.invalidate(goalsProvider),
        );
      },
    );
  }
}

class _GoalList extends StatelessWidget {
  const _GoalList({
    required this.goals,
    this.onAddPressed,
  });

  final List<FinancialGoal> goals;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.blue.withOpacity(.12),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Colors.blue,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      "No hay metas financieras",
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Establece metas financieras para alcanzar tus objetivos económicos.",
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: onAddPressed,
                      icon: const Icon(Icons.add),
                      label: const Text("Crear Meta"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      itemCount: goals.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final FinancialGoal goal = goals[index];
        final double progress = _goalProgress(goal);
        final bool isCompleted = progress >= 1;

        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  goal.name,
                                  style: AppTypography.title.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isCompleted) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: Text(
                                    "Completada",
                                    style: AppTypography.label.copyWith(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Objetivo: ${_formatCurrency(goal.targetAmount)}',
                            style: AppTypography.body.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: AppTypography.headline.copyWith(
                            color: isCompleted ? Colors.green.shade700 : Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Progreso',
                          style: AppTypography.label.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  color: isCompleted ? Colors.green : Colors.blue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progreso Actual',
                            style: AppTypography.label.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatCurrency(goal.currentAmount),
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Fecha Límite',
                            style: AppTypography.label.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatDate(context, goal.deadline),
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GoalErrorState extends StatelessWidget {
  const _GoalErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 50,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Error al cargar las metas",
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "No fue posible obtener la lista de metas. Verifica tu conexión e intenta nuevamente.",
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddGoalSheet extends ConsumerStatefulWidget {
  const _AddGoalSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  ConsumerState<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<_AddGoalSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _currentController = TextEditingController();

  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  String _selectedPriority = "Media";
  String _selectedStatus = "Activa";
  bool _isSaving = false;

  static const List<String> _priorityOptions = [
    "Alta",
    "Media",
    "Baja",
  ];

  static const List<String> _statusOptions = [
    "Activa",
    "En Progreso",
    "Pausada",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Nueva Meta Financiera",
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Define una meta para alcanzar tus objetivos financieros",
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Meta",
                  hintText: "Ej: Ahorro para viaje, Fondo de emergencia",
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor, ingresa un nombre para la meta.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Monto Objetivo",
                  hintText: "0.00",
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: _amountValidator,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _currentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Monto Actual",
                  hintText: "0.00",
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: _amountValidator,
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Fecha Límite",
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(
                    _formatDate(context, _deadline),
                    style: AppTypography.body,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: "Prioridad",
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: _priorityOptions.map(
                  (String option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                ).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: "Estado",
                  prefixIcon: Icon(Icons.timeline),
                ),
                items: _statusOptions.map(
                  (String option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                ).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? "Guardando..." : "Guardar Meta",
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _deadline = pickedDate;
      });
    }
  }

  String? _amountValidator(String? value) {
    final double? parsed = double.tryParse((value ?? '').trim());
    if (parsed == null || parsed < 0) {
      return 'Ingresa un monto válido mayor a cero.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final FinancialGoalRepository repository = FinancialGoalRepository(
        await ref.read(isarProvider.future),
      );

      await repository.save(
        FinancialGoal(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          targetAmount: double.parse(_targetController.text.trim()),
          currentAmount: double.parse(_currentController.text.trim()),
          deadline: _deadline,
          priority: _selectedPriority,
          status: _selectedStatus,
        ),
      );

      widget.onSaved();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Meta financiera creada exitosamente."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al crear la meta: $error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

double _goalProgress(FinancialGoal goal) {
  if (goal.targetAmount <= 0) {
    return 0;
  }
  return goal.currentAmount / goal.targetAmount;
}

String _formatCurrency(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

String _formatDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatMediumDate(date);
}