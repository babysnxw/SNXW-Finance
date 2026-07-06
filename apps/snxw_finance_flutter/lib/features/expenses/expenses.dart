import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import '../../core/repositories/expense_repository.dart';
import '../../shared/design/design.dart';
import '../../shared/models/models.dart';

final FutureProvider<List<Expense>> expensesProvider = FutureProvider<List<Expense>>(
  (ref) async {
    final repository = ExpenseRepository(await ref.watch(isarProvider.future));
    return repository.list();
  },
);

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Expense>> expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddExpenseSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: expensesAsync.when(
          data: (List<Expense> expenses) => _ExpenseList(expenses: expenses),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) => _ExpenseErrorState(
            error: error,
            onRetry: () => ref.invalidate(expensesProvider),
          ),
        ),
      ),
    );
  }

  void _openAddExpenseSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return _AddExpenseSheet(
          onSaved: () => ref.invalidate(expensesProvider),
        );
      },
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
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
                    Icon(Icons.receipt_long_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No expenses yet',
                      style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Add your first expense to start tracking spending.',
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
      itemCount: expenses.length,
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final Expense expense = expenses[index];

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              child: const Icon(Icons.trending_down_rounded),
            ),
            title: Text(
              expense.category,
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(_formatCurrency(expense.amount), style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_formatDate(context, expense.date), style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  if (expense.recurrence != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text('Recurrence: ${expense.recurrence}', style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    expense.isEssential ? 'Essential expense' : 'Non-essential expense',
                    style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (expense.notes != null && expense.notes!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text(expense.notes!, style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

class _ExpenseErrorState extends StatelessWidget {
  const _ExpenseErrorState({required this.error, required this.onRetry});

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
            Text('Unable to load expenses', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
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

class _AddExpenseSheet extends ConsumerStatefulWidget {
  const _AddExpenseSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  ConsumerState<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<_AddExpenseSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedRecurrence;
  bool _isEssential = false;
  bool _isSaving = false;

  static const List<String> _recurrenceOptions = <String>[
    'Weekly',
    'Biweekly',
    'Monthly',
    'Yearly',
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _notesController.dispose();
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
              Text('Add Expense', style: AppTypography.headline.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _categoryController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required';
                  }

                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (String? value) {
                  final double? parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(_formatDate(context, _selectedDate)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String?>(
                initialValue: _selectedRecurrence,
                decoration: const InputDecoration(labelText: 'Recurrence'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(value: null, child: Text('One-time')),
                  ..._recurrenceOptions.map(
                    (String option) => DropdownMenuItem<String?>(value: option, child: Text(option)),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedRecurrence = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Essential'),
                subtitle: Text(
                  'Mark this expense as essential.',
                  style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                value: _isEssential,
                onChanged: (bool value) {
                  setState(() {
                    _isEssential = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final ExpenseRepository repository = ExpenseRepository(await ref.read(isarProvider.future));
      await repository.save(
        Expense(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          category: _categoryController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          date: _selectedDate,
          recurrence: _selectedRecurrence,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          isEssential: _isEssential,
        ),
      );

      widget.onSaved();
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save expense: $error')),
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