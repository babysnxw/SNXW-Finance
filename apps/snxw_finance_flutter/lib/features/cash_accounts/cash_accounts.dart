import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database_provider.dart';
import '../../core/repositories/cash_account_repository.dart';
import '../../shared/design/design.dart';
import '../../shared/models/models.dart';

final FutureProvider<List<CashAccount>> cashAccountsProvider = FutureProvider<List<CashAccount>>(
  (ref) async {
    final repository = CashAccountRepository(await ref.watch(isarProvider.future));
    return repository.list();
  },
);

class CashAccountsPage extends ConsumerWidget {
  const CashAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CashAccount>> accountsAsync = ref.watch(cashAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text("Cuentas de Efectivo"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddAccountSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Nueva Cuenta"),
      ),
      body: SafeArea(
        child: accountsAsync.when(
          data: (List<CashAccount> accounts) => _CashAccountList(
            accounts: accounts,
            onAddPressed: () => _openAddAccountSheet(context, ref),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (Object error, StackTrace stackTrace) => _CashAccountErrorState(
            error: error,
            onRetry: () => ref.invalidate(cashAccountsProvider),
          ),
        ),
      ),
    );
  }

  void _openAddAccountSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return _AddCashAccountSheet(
          onSaved: () => ref.invalidate(cashAccountsProvider),
        );
      },
    );
  }
}

class _CashAccountList extends StatelessWidget {
  const _CashAccountList({
    required this.accounts,
    this.onAddPressed,
  });

  final List<CashAccount> accounts;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
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
                      backgroundColor: Colors.purple.withOpacity(.12),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.purple,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      "No hay cuentas registradas",
                      textAlign: TextAlign.center,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Crea cuentas para organizar mejor tu dinero y finanzas.",
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: onAddPressed,
                      icon: const Icon(Icons.add),
                      label: const Text("Crear Cuenta"),
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
      itemCount: accounts.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final CashAccount account = accounts[index];

        return Card(
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(AppSpacing.md),
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(.15),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.purple,
              ),
            ),
            title: Text(
              account.name,
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
                    _formatCurrency(account.currentBalance),
                    style: AppTypography.headline.copyWith(
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tipo: ${account.type} | Moneda: ${account.currency}",
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}

class _CashAccountErrorState extends StatelessWidget {
  const _CashAccountErrorState({
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
              "Error al cargar las cuentas",
              style: AppTypography.title.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "No fue posible obtener la lista de cuentas. Verifica tu conexión e intenta nuevamente.",
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

class _AddCashAccountSheet extends ConsumerStatefulWidget {
  const _AddCashAccountSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  ConsumerState<_AddCashAccountSheet> createState() => _AddCashAccountSheetState();
}

class _AddCashAccountSheetState extends ConsumerState<_AddCashAccountSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  String _selectedType = "Efectivo";
  String _selectedCurrency = "USD";
  bool _isSaving = false;

  static const List<String> _typeOptions = [
    "Efectivo",
    "Cuenta de Ahorro",
    "Cuenta Corriente",
    "Tarjeta de Crédito",
  ];

  static const List<String> _currencyOptions = [
    "USD",
    "EUR",
    "MXN",
    "COP",
    "ARS",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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
                "Registrar Nueva Cuenta",
                style: AppTypography.headline.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Completa los campos para registrar una nueva cuenta",
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la Cuenta",
                  hintText: "Ej: Cuenta de Ahorros, Billetera, Tarjeta",
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor, ingresa un nombre para la cuenta.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: "Tipo de Cuenta",
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _typeOptions.map(
                  (String option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                ).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Saldo Inicial",
                  hintText: "0.00",
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                validator: (value) {
                  final balance = double.tryParse(value ?? "");

                  if (balance == null || balance < 0) {
                    return "Ingresa un saldo válido mayor o igual a cero.";
                  }

                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: "Moneda",
                  prefixIcon: Icon(Icons.currency_exchange),
                ),
                items: _currencyOptions.map(
                  (String option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                ).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
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
                  _isSaving ? "Guardando..." : "Guardar Cuenta",
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
      final repository = CashAccountRepository(
        await ref.read(isarProvider.future),
      );

      await repository.save(
        CashAccount(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          type: _selectedType,
          currentBalance: double.parse(_balanceController.text),
          currency: _selectedCurrency,
        ),
      );

      widget.onSaved();

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cuenta registrada exitosamente."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al registrar la cuenta: $e"),
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