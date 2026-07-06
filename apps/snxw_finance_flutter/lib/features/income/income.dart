import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
			appBar: AppBar(title: const Text('Income')),
			floatingActionButton: FloatingActionButton(
				onPressed: () => _openAddIncomeSheet(context, ref),
				child: const Icon(Icons.add),
			),
			body: SafeArea(
				child: incomesAsync.when(
					data: (List<Income> incomes) => _IncomeList(incomes: incomes),
					loading: () => const Center(child: CircularProgressIndicator()),
					error: (Object error, StackTrace stackTrace) => _IncomeErrorState(
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
			builder: (BuildContext context) {
				return _AddIncomeSheet(
					onSaved: () => ref.invalidate(incomesProvider),
				);
			},
		);
	}
}

class _IncomeList extends StatelessWidget {
	const _IncomeList({required this.incomes});

	final List<Income> incomes;

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
									children: <Widget>[
										Icon(Icons.payments_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
										const SizedBox(height: AppSpacing.md),
										Text(
											'No incomes yet',
											style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
										),
										const SizedBox(height: AppSpacing.sm),
										Text(
											'Add your first income to start tracking your cash flow.',
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
			itemCount: incomes.length,
			separatorBuilder: (BuildContext context, int index) => const SizedBox(height: AppSpacing.md),
			itemBuilder: (BuildContext context, int index) {
				final Income income = incomes[index];

				return Card(
					child: ListTile(
						contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
						leading: CircleAvatar(
							backgroundColor: Theme.of(context).colorScheme.primaryContainer,
							foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
							child: const Icon(Icons.trending_up_rounded),
						),
						title: Text(
							income.source,
							style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
						),
						subtitle: Padding(
							padding: const EdgeInsets.only(top: AppSpacing.xs),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								mainAxisSize: MainAxisSize.min,
								children: <Widget>[
									Text(_formatCurrency(income.amount), style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
									const SizedBox(height: AppSpacing.xs),
									Text(_formatDate(context, income.date), style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
									if (income.recurrence != null) ...<Widget>[
										const SizedBox(height: AppSpacing.xs),
										Text('Recurrence: ${income.recurrence}', style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
									],
									if (income.notes != null && income.notes!.trim().isNotEmpty) ...<Widget>[
										const SizedBox(height: AppSpacing.xs),
										Text(income.notes!, style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
	const _IncomeErrorState({required this.error, required this.onRetry});

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
						Text('Unable to load incomes', style: AppTypography.title.copyWith(fontWeight: FontWeight.w700)),
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

class _AddIncomeSheet extends ConsumerStatefulWidget {
	const _AddIncomeSheet({required this.onSaved});

	final VoidCallback onSaved;

	@override
	ConsumerState<_AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends ConsumerState<_AddIncomeSheet> {
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	final TextEditingController _sourceController = TextEditingController();
	final TextEditingController _amountController = TextEditingController();
	final TextEditingController _notesController = TextEditingController();
	DateTime _selectedDate = DateTime.now();
	String? _selectedRecurrence;
	bool _isSaving = false;

	static const List<String> _recurrenceOptions = <String>[
		'Weekly',
		'Biweekly',
		'Monthly',
		'Yearly',
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
							Text('Add Income', style: AppTypography.headline.copyWith(fontWeight: FontWeight.w700)),
							const SizedBox(height: AppSpacing.lg),
							TextFormField(
								controller: _sourceController,
								textInputAction: TextInputAction.next,
								decoration: const InputDecoration(labelText: 'Source'),
								validator: (String? value) {
									if (value == null || value.trim().isEmpty) {
										return 'Source is required';
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
									: const Text('Save Income'),
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
			final IncomeRepository repository = IncomeRepository(await ref.read(isarProvider.future));
			await repository.save(
				Income(
					id: DateTime.now().microsecondsSinceEpoch.toString(),
					source: _sourceController.text.trim(),
					amount: double.parse(_amountController.text.trim()),
					date: _selectedDate,
					recurrence: _selectedRecurrence,
					notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
				SnackBar(content: Text('Could not save income: $error')),
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