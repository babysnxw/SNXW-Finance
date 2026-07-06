import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
			appBar: AppBar(title: const Text('Debts')),
			floatingActionButton: FloatingActionButton(
				onPressed: () => _openAddDebtSheet(context, ref),
				child: const Icon(Icons.add),
			),
			body: SafeArea(
				child: debtsAsync.when(
					data: (List<Debt> debts) => _DebtList(debts: debts),
					loading: () => const Center(child: CircularProgressIndicator()),
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
	const _DebtList({required this.debts});

	final List<Debt> debts;

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
									children: <Widget>[
										Icon(Icons.payments_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
										const SizedBox(height: AppSpacing.md),
										Text('No debts yet', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
										const SizedBox(height: AppSpacing.sm),
										Text(
											'Create a debt to track principal, balance, interest, and due day.',
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
			itemCount: debts.length,
			separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.md),
			itemBuilder: (BuildContext context, int index) {
				final Debt debt = debts[index];

				return Card(
					child: ListTile(
						contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
						leading: CircleAvatar(
							backgroundColor: Theme.of(context).colorScheme.errorContainer,
							foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
							child: const Icon(Icons.account_balance_wallet_rounded),
						),
						title: Text(debt.name, style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
						subtitle: Padding(
							padding: const EdgeInsets.only(top: AppSpacing.xs),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								mainAxisSize: MainAxisSize.min,
								children: <Widget>[
									Text('Outstanding: ${_formatCurrency(debt.outstandingBalance)}', style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
									const SizedBox(height: AppSpacing.xs),
									Text('Principal: ${_formatCurrency(debt.principal)}', style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
									const SizedBox(height: AppSpacing.xs),
									Text('Interest: ${debt.interestRate.toStringAsFixed(2)}%', style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
								],
							),
						),
						trailing: Text('Due ${debt.dueDay}', style: AppTypography.label.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
					),
				);
			},
		);
	}
}

class _DebtErrorState extends StatelessWidget {
	const _DebtErrorState({required this.error, required this.onRetry});

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
						Text('Unable to load debts', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
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
	final TextEditingController _balanceController = TextEditingController();
	final TextEditingController _interestController = TextEditingController();
	final TextEditingController _minimumPaymentController = TextEditingController();
	final TextEditingController _dueDayController = TextEditingController();
	String _selectedStatus = 'active';
	bool _isSaving = false;

	static const List<_DebtStatusOption> _statuses = <_DebtStatusOption>[
		_DebtStatusOption(value: 'active', label: 'Active'),
		_DebtStatusOption(value: 'paused', label: 'Paused'),
		_DebtStatusOption(value: 'paid', label: 'Paid'),
	];

	@override
	void dispose() {
		_nameController.dispose();
		_principalController.dispose();
		_balanceController.dispose();
		_interestController.dispose();
		_minimumPaymentController.dispose();
		_dueDayController.dispose();
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
							Text('Add Debt', style: AppTypography.headline.copyWith(fontWeight: FontWeight.w700)),
							const SizedBox(height: AppSpacing.lg),
							TextFormField(
								controller: _nameController,
								decoration: const InputDecoration(labelText: 'Name'),
								validator: (String? value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
							),
							const SizedBox(height: AppSpacing.md),
							TextFormField(
								controller: _principalController,
								keyboardType: const TextInputType.numberWithOptions(decimal: true),
								decoration: const InputDecoration(labelText: 'Principal'),
								validator: _amountValidator,
							),
							const SizedBox(height: AppSpacing.md),
							TextFormField(
								controller: _balanceController,
								keyboardType: const TextInputType.numberWithOptions(decimal: true),
								decoration: const InputDecoration(labelText: 'Outstanding Balance'),
								validator: _amountValidator,
							),
							const SizedBox(height: AppSpacing.md),
							TextFormField(
								controller: _interestController,
								keyboardType: const TextInputType.numberWithOptions(decimal: true),
								decoration: const InputDecoration(labelText: 'Interest Rate (%)'),
								validator: _amountValidator,
							),
							const SizedBox(height: AppSpacing.md),
							TextFormField(
								controller: _minimumPaymentController,
								keyboardType: const TextInputType.numberWithOptions(decimal: true),
								decoration: const InputDecoration(labelText: 'Minimum Payment'),
								validator: _amountValidator,
							),
							const SizedBox(height: AppSpacing.md),
							TextFormField(
								controller: _dueDayController,
								keyboardType: TextInputType.number,
								decoration: const InputDecoration(labelText: 'Due Day'),
								validator: (String? value) {
									final int? parsed = int.tryParse((value ?? '').trim());
									if (parsed == null || parsed < 1 || parsed > 31) {
										return 'Enter a day between 1 and 31';
									}
									return null;
								},
							),
							const SizedBox(height: AppSpacing.md),
							DropdownButtonFormField<String>(
								initialValue: _selectedStatus,
								decoration: const InputDecoration(labelText: 'Status'),
								items: _statuses
										.map((_DebtStatusOption item) => DropdownMenuItem<String>(value: item.value, child: Text(item.label)))
										.toList(growable: false),
								onChanged: (String? value) {
									if (value == null) {
										return;
									}
									setState(() {
										_selectedStatus = value;
									});
								},
							),
							const SizedBox(height: AppSpacing.lg),
							FilledButton(
								onPressed: _isSaving ? null : _save,
								child: _isSaving
										? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
										: const Text('Save Debt'),
							),
						],
					),
				),
			),
		);
	}

	String? _amountValidator(String? value) {
		final double? parsed = double.tryParse((value ?? '').trim());
		if (parsed == null) {
			return 'Enter a valid amount';
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
			final DebtRepository repository = DebtRepository(await ref.read(isarProvider.future));
			await repository.save(
				Debt(
					id: DateTime.now().microsecondsSinceEpoch.toString(),
					name: _nameController.text.trim(),
					principal: double.parse(_principalController.text.trim()),
					outstandingBalance: double.parse(_balanceController.text.trim()),
					interestRate: double.parse(_interestController.text.trim()),
					minimumPayment: double.parse(_minimumPaymentController.text.trim()),
					dueDay: int.parse(_dueDayController.text.trim()),
					status: _selectedStatus,
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

String _formatCurrency(double value) {
	return '\$${value.toStringAsFixed(2)}';
}

class _DebtStatusOption {
	const _DebtStatusOption({required this.value, required this.label});

	final String value;
	final String label;
}