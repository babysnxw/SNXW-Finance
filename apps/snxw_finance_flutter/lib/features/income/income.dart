import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database_provider.dart';
import '../../core/repositories/income_repository.dart';
import '../../shared/design/design.dart';
import '../../shared/models/models.dart';

final FutureProvider<List<Income>> incomesProvider = FutureProvider<List<Income>>(
  (ref) async {
    final repository = IncomeRepository(await ref.watch(isarProvider.future));
    return repository.list();
  },
);

class IncomePage extends ConsumerWidget {
  const IncomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Income>> incomesAsync = ref.watch(incomesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text("Registro de Ingresos"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddIncomeSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Nuevo Ingreso"),
      ),
      body: SafeArea(
        child: incomesAsync.when(
          data: (incomes) => _IncomeList(
            incomes: incomes,
            onAddPressed: () => _openAddIncomeSheet(context, ref),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => _IncomeErrorState(
            error: error,
            onRetry: () => ref.invalidate(incomesProvider),
          ),
        ),
      ),
    );
  }

  void _openAddIncomeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AddIncomeSheet(
        onSaved: () => ref.invalidate(incomesProvider),
      ),
    );
  }
}

class _IncomeList extends StatelessWidget {
  const _IncomeList({
    required this.incomes,
    this.onAddPressed,
  });

  final List<Income> incomes;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
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
                      backgroundColor: Colors.green.withOpacity(.12),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: Colors.green,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      "No hay ingresos registrados",
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Comienza a registrar tus ingresos para llevar un control financiero efectivo.",
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: onAddPressed,
                      icon: const Icon(Icons.add),
                      label: const Text("Registrar Ingreso"),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: incomes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final income = incomes[index];

        return Card(
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(.15),
              child: const Icon(
                Icons.attach_money_rounded,
                color: Colors.green,
              ),
            ),
            title: Text(
              income.source,
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatCurrency(income.amount),
                    style: AppTypography.headline.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fecha: ${_formatDate(context, income.date)}",
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (income.recurrence != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Frecuencia: ${income.recurrence}",
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (income.notes != null && income.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      income.notes!,
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IncomeErrorState extends StatelessWidget {
  const _IncomeErrorState({
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
              "Error al cargar los ingresos",
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "No fue posible obtener la lista de ingresos. Verifica tu conexión e intenta nuevamente.",
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

class _AddIncomeSheet extends ConsumerStatefulWidget {
  const _AddIncomeSheet({
    required this.onSaved,
  });

  final VoidCallback onSaved;

  @override
  ConsumerState<_AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends ConsumerState<_AddIncomeSheet> {
  final _formKey = GlobalKey<FormState>();

  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  String? _selectedRecurrence;

  bool _isSaving = false;

  static const List<String> _recurrenceOptions = [
    "Semanal",
    "Quincenal",
    "Mensual",
    "Anual",
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Registrar Nuevo Ingreso",
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Completa los campos para registrar un nuevo ingreso",
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: "Fuente de Ingreso",
                  hintText: "Ej: Salario, Freelance, Inversión",
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor, especifica la fuente de ingreso.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Monto",
                  hintText: "0.00",
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? "");

                  if (amount == null || amount <= 0) {
                    return "Ingresa un monto válido mayor a cero.";
                  }

                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Fecha de Ingreso",
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(
                    _formatDate(context, _selectedDate),
                    style: AppTypography.body,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String?>(
                initialValue: _selectedRecurrence,
                decoration: const InputDecoration(
                  labelText: "Frecuencia",
                  prefixIcon: Icon(Icons.repeat_rounded),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Sin repetición"),
                  ),
                  ..._recurrenceOptions.map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRecurrence = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Notas Adicionales",
                  hintText: "Agrega información extra sobre este ingreso",
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? "Guardando..." : "Guardar Ingreso",
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = IncomeRepository(
        await ref.read(isarProvider.future),
      );

      await repository.save(
        Income(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          source: _sourceController.text.trim(),
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          recurrence: _selectedRecurrence,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ),
      );

      widget.onSaved();

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingreso registrado exitosamente."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al registrar el ingreso: $e"),
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

String _formatCurrency(double value) {
  return "\$${value.toStringAsFixed(2)}";
}

String _formatDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatMediumDate(date);
}