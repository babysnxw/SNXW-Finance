import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database_provider.dart';
import '../../core/repositories/payment_repository.dart';
import '../../shared/design/design.dart';
import '../../shared/models/models.dart';

final FutureProvider<List<Payment>> paymentsProvider = FutureProvider<List<Payment>>(
  (ref) async {
    final repository = PaymentRepository(await ref.watch(isarProvider.future));
    return repository.list();
  },
);

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Payment>> paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text("Registro de Pagos"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPaymentSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Nuevo Pago"),
      ),
      body: SafeArea(
        child: paymentsAsync.when(
          data: (List<Payment> payments) => _PaymentList(
            payments: payments,
            onAddPressed: () => _openAddPaymentSheet(context, ref),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => _PaymentErrorState(
            error: error,
            onRetry: () => ref.invalidate(paymentsProvider),
          ),
        ),
      ),
    );
  }

  void _openAddPaymentSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return _AddPaymentSheet(
          onSaved: () => ref.invalidate(paymentsProvider),
        );
      },
    );
  }
}

class _PaymentList extends StatelessWidget {
  const _PaymentList({
    required this.payments,
    this.onAddPressed,
  });

  final List<Payment> payments;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
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
                      backgroundColor: Colors.teal.withOpacity(.12),
                      child: const Icon(
                        Icons.payment_rounded,
                        color: Colors.teal,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      "No hay pagos registrados",
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Registra tus pagos para llevar un mejor control financiero.",
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: onAddPressed,
                      icon: const Icon(Icons.add),
                      label: const Text("Registrar Pago"),
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
      itemCount: payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final Payment payment = payments[index];

        return Card(
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(.15),
              child: const Icon(
                Icons.payment_rounded,
                color: Colors.teal,
              ),
            ),
            title: Text(
              payment.description,
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
                    _formatCurrency(payment.amount),
                    style: AppTypography.headline.copyWith(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Fecha: ${_formatDate(context, payment.date)}",
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.status).withOpacity(.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      payment.status,
                      style: AppTypography.label.copyWith(
                        color: _getStatusColor(payment.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      payment.notes!,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case "Pagado":
        return Colors.green;
      case "Pendiente":
        return Colors.orange;
      case "Atrasado":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _PaymentErrorState extends StatelessWidget {
  const _PaymentErrorState({
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
              "Error al cargar los pagos",
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "No fue posible obtener la lista de pagos. Verifica tu conexión e intenta nuevamente.",
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

class _AddPaymentSheet extends ConsumerStatefulWidget {
  const _AddPaymentSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  ConsumerState<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<_AddPaymentSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = "Pendiente";
  bool _isSaving = false;

  static const List<String> _statusOptions = [
    "Pendiente",
    "Pagado",
    "Atrasado",
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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
                "Registrar Nuevo Pago",
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Completa los campos para registrar un nuevo pago",
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  hintText: "Ej: Pago de tarjeta, Servicio, Renta",
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor, ingresa una descripción del pago.";
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
                    labelText: "Fecha del Pago",
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(
                    _formatDate(context, _selectedDate),
                    style: AppTypography.body,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: "Estado del Pago",
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
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Notas Adicionales",
                  hintText: "Agrega información extra sobre este pago",
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
                  _isSaving ? "Guardando..." : "Guardar Pago",
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
      final repository = PaymentRepository(
        await ref.read(isarProvider.future),
      );

      await repository.save(
        Payment(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          description: _descriptionController.text.trim(),
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          status: _selectedStatus,
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
          content: Text("Pago registrado exitosamente."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al registrar el pago: $e"),
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

String _formatDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatMediumDate(date);
}