import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database_provider.dart';
import '../../core/repositories/debt_repository.dart';
import '../../shared/design/design.dart';
import '../../shared/models/models.dart';

final FutureProvider<List<Debt>> debtsProvider = FutureProvider<List<Debt>>(
  (ref) async {
    final repository = DebtRepository(await ref.watch(isarProvider.future));
    return repository.list();
  },
);

class DebtsPage extends ConsumerWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Debt>> debtsAsync = ref.watch(debtsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text("Registro de Deudas"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDebtSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Nueva Deuda"),
      ),
      body: SafeArea(
        child: debtsAsync.when(
          data: (List<Debt> debts) => _DebtList(
            debts: debts,
            onAddPressed: () => _openAddDebtSheet(context, ref),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => _DebtErrorState(
            error: error,
            onRetry: () => ref.invalidate(debtsProvider),
          ),
        ),
      ),
    );
  }

  void _openAddDebtSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return _AddDebtSheet(
          onSaved: () => ref.invalidate(debtsProvider),
        );
      },
    );
  }
}

class _DebtList extends StatelessWidget {
  const _DebtList({
    required this.debts,
    this.onAddPressed,
  });

  final List<Debt> debts;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
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
                      backgroundColor: Colors.orange.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.credit_card_rounded,
                        color: Colors.orange,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      "No hay deudas registradas",
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Registra tus deudas para mantener un control financiero saludable.",
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: onAddPressed,
                      icon: const Icon(Icons.add),
                      label: const Text("Registrar Deuda"),
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
      itemCount: debts.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final Debt debt = debts[index];

        return Card(
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.15),
              child: const Icon(
                Icons.credit_card_rounded,
                color: Colors.orange,
              ),
            ),
            title: Text(
              debt.name,
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
                    _formatCurrency(debt.principal),
                    style: AppTypography.headline.copyWith(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Saldo: ${_formatCurrency(debt.outstandingBalance)}",
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tasa: ${debt.interestRate}% | Pago mínimo: ${_formatCurrency(debt.minimumPayment)} | Día de pago: ${debt.dueDay}",
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(debt.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      debt.status,
                      style: AppTypography.label.copyWith(
                        color: _getStatusColor(debt.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Activa":
        return Colors.green;
      case "En Progreso":
        return Colors.blue;
      case "Pausada":
        return Colors.orange;
      case "Completada":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _DebtErrorState extends StatelessWidget {
  const _DebtErrorState({
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
              "Error al cargar las deudas",
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "No fue posible obtener la lista de deudas. Verifica tu conexión e intenta nuevamente.",
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

class _AddDebtSheet extends ConsumerStatefulWidget {
  const _AddDebtSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  ConsumerState<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends ConsumerState<_AddDebtSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _principalController = TextEditingController();
  final TextEditingController _outstandingController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _minPaymentController = TextEditingController();
  final TextEditingController _dueDayController = TextEditingController();

  String _selectedStatus = "Activa";
  bool _isSaving = false;

  static const List<String> _statusOptions = [
    "Activa",
    "En Progreso",
    "Pausada",
    "Completada",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _principalController.dispose();
    _outstandingController.dispose();
    _interestController.dispose();
    _minPaymentController.dispose();
    _dueDayController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Registrar Nueva Deuda",
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Completa los campos para registrar una nueva deuda",
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Deuda",
                  hintText: "Ej: Tarjeta de Crédito, Préstamo Personal",
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor, ingresa un nombre para la deuda.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _principalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Capital Inicial",
                  hintText: "0.00",
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? "");
                  if (amount == null || amount <= 0) {
                    return "Ingresa un capital válido mayor a cero.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _outstandingController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Saldo Pendiente",
                  hintText: "0.00",
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? "");
                  if (amount == null || amount < 0) {
                    return "Ingresa un saldo pendiente válido.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _interestController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Tasa de Interés (%)",
                        hintText: "Ej: 25.5",
                        prefixIcon: Icon(Icons.percent),
                      ),
                      validator: (value) {
                        final rate = double.tryParse(value ?? "");
                        if (rate == null || rate < 0) {
                          return "Ingresa una tasa válida.";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextFormField(
                      controller: _minPaymentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Pago Mínimo",
                        hintText: "0.00",
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value ?? "");
                        if (amount == null || amount < 0) {
                          return "Ingresa un pago mínimo válido.";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dueDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Día de Pago",
                        hintText: "Ej: 15",
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      validator: (value) {
                        final day = int.tryParse(value ?? "");
                        if (day == null || day < 1 || day > 31) {
                          return "Ingresa un día válido (1-31).";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                  ),
                ],
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
                  _isSaving ? "Guardando..." : "Guardar Deuda",
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = DebtRepository(
        await ref.read(isarProvider.future),
      );

      await repository.save(
        Debt(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          principal: double.parse(_principalController.text),
          outstandingBalance: double.parse(_outstandingController.text),
          interestRate: double.parse(_interestController.text),
          minimumPayment: double.parse(_minPaymentController.text),
          dueDay: int.parse(_dueDayController.text),
          status: _selectedStatus,
        ),
      );

      widget.onSaved();

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deuda registrada exitosamente."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al registrar la deuda: $e"),
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
  return '\$${value.toStringAsFixed(2)}';
}