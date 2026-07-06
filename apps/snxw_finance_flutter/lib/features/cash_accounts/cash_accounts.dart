import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      appBar: AppBar(title: const Text('Cash Accounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddCashAccountSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: accountsAsync.when(
          data: (List<CashAccount> accounts) => _CashAccountList(accounts: accounts),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => _CashAccountErrorState(
            error: error,
            onRetry: () => ref.invalidate(cashAccountsProvider),
          ),
        ),
      ),
    );
  }

  void _openAddCashAccountSheet(BuildContext context, WidgetRef ref) {
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
  const _CashAccountList({required this.accounts});

  final List<CashAccount> accounts;

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
                  children: <Widget>[
                    Icon(Icons.account_balance_wallet_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text('No cash accounts yet', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Add cash, bank accounts, or debit cards to track available money.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
      itemCount: accounts.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final CashAccount account = accounts[index];

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: const Icon(Icons.account_balance_wallet_rounded),
            ),
            title: Text(account.name, style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(_formatCurrency(account.currentBalance, account.currency), style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_cashAccountTypeLabel(account.type), style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
  const _CashAccountErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Unable to load cash accounts', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Text(error.toString(), textAlign: TextAlign.center, style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
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
  final TextEditingController _currencyController = TextEditingController(text: 'USD');
  String _selectedType = 'cash';
  bool _isSaving = false;

  static const List<_CashAccountTypeOption> _types = <_CashAccountTypeOption>[
    _CashAccountTypeOption(value: 'cash', label: 'Cash'),
    _CashAccountTypeOption(value: 'bankAccount', label: 'Bank Account'),
    _CashAccountTypeOption(value: 'debitCard', label: 'Debit Card'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, viewInsets.bottom + AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Add Cash Account', style: AppTypography.headline.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (String? value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: _types
                    .map((_CashAccountTypeOption item) => DropdownMenuItem<String>(value: item.value, child: Text(item.label)))
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Current Balance'),
                validator: (String? value) {
                  final double? parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _currencyController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Currency'),
                validator: (String? value) => value == null || value.trim().isEmpty ? 'Currency is required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Cash Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final CashAccountRepository repository = CashAccountRepository(await ref.read(isarProvider.future));
      await repository.save(
        CashAccount(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          type: _selectedType,
          currentBalance: double.parse(_balanceController.text.trim()),
          currency: _currencyController.text.trim().toUpperCase(),
        ),
      );

      widget.onSaved();
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

String _cashAccountTypeLabel(String type) {
  switch (type) {
    case 'bankAccount':
      return 'Bank Account';
    case 'debitCard':
      return 'Debit Card';
    default:
      return 'Cash';
  }
}

String _formatCurrency(double value, String currency) {
  return '$currency ${value.toStringAsFixed(2)}';
}

class _CashAccountTypeOption {
  const _CashAccountTypeOption({required this.value, required this.label});

  final String value;
  final String label;
}