import 'package:flutter/material.dart';

import '../../shared/design/design.dart';

class DashboardPage extends StatelessWidget {
	const DashboardPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Dashboard'),
			),
			body: const SafeArea(
				child: _DashboardContent(),
			),
		);
	}
}

class _DashboardContent extends StatelessWidget {
	const _DashboardContent();

	@override
	Widget build(BuildContext context) {
		return LayoutBuilder(
			builder: (BuildContext context, BoxConstraints constraints) {
					final double horizontalPadding = constraints.maxWidth >= 900 ? AppSpacing.xl : AppSpacing.lg;
					final double maxContentWidth = constraints.maxWidth >= 1200 ? 1120 : double.infinity;
				final int summaryColumns = constraints.maxWidth >= 960
					? 3
					: constraints.maxWidth >= 640
						? 2
						: 1;

				return Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: maxContentWidth),
						child: SingleChildScrollView(
							padding: EdgeInsets.fromLTRB(horizontalPadding, AppSpacing.xl, horizontalPadding, AppSpacing.xl),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									const _GreetingSection(),
									const SizedBox(height: AppSpacing.xl),
									const _SectionHeader(title: 'Financial Summary'),
									const SizedBox(height: AppSpacing.md),
									_SummaryCardsGrid(columns: summaryColumns),
									const SizedBox(height: AppSpacing.xl),
									const _SectionHeader(title: 'Upcoming Payments'),
									const SizedBox(height: AppSpacing.md),
									const _UpcomingPaymentsCard(),
									const SizedBox(height: AppSpacing.xl),
									const _SectionHeader(title: 'Quick Actions'),
									const SizedBox(height: AppSpacing.md),
									const _QuickActionsSection(),
								],
							),
						),
					),
				);
			},
		);
	}
}

class _GreetingSection extends StatelessWidget {
	const _GreetingSection();

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				Text(
					'Good morning 👋',
					style: AppTypography.title.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
				),
				const SizedBox(height: AppSpacing.sm),
				Text(
					'Take control.\nBuild your future.',
					style: AppTypography.display.copyWith(color: Theme.of(context).colorScheme.onSurface),
				),
			],
		);
	}
}

class _SectionHeader extends StatelessWidget {
	const _SectionHeader({required this.title});

	final String title;

	@override
	Widget build(BuildContext context) {
		return Text(
			title,
			style: AppTypography.title.copyWith(
				color: Theme.of(context).colorScheme.onSurface,
				fontWeight: FontWeight.w700,
			),
		);
	}
}

class _SummaryCardsGrid extends StatelessWidget {
	const _SummaryCardsGrid({required this.columns});

	final int columns;

	@override
	Widget build(BuildContext context) {
		final List<_SummaryCardData> items = <_SummaryCardData>[
			const _SummaryCardData(title: 'Net Worth', value: r'$0.00'),
			const _SummaryCardData(title: 'Monthly Income', value: r'$0.00'),
			const _SummaryCardData(title: 'Monthly Expenses', value: r'$0.00'),
		];

		return Wrap(
			runSpacing: AppSpacing.md,
			spacing: AppSpacing.md,
			children: items
				.map(
					(_SummaryCardData item) => SizedBox(
						width: _cardWidthForColumns(context, columns),
						child: _SummaryCard(title: item.title, value: item.value),
					),
				)
				.toList(),
		);
	}

	double _cardWidthForColumns(BuildContext context, int columns) {
		final double availableWidth = MediaQuery.sizeOf(context).width;
		final double horizontalPadding = availableWidth >= 900 ? AppSpacing.xl : AppSpacing.lg;
		final double contentWidth = availableWidth >= 1200 ? 1120 : availableWidth;
		final double spacing = AppSpacing.md * (columns - 1);
		return (contentWidth - (horizontalPadding * 2) - spacing) / columns;
	}
}

class _SummaryCardData {
	const _SummaryCardData({required this.title, required this.value});

	final String title;
	final String value;
}

class _SummaryCard extends StatelessWidget {
	const _SummaryCard({required this.title, required this.value});

	final String title;
	final String value;

	@override
	Widget build(BuildContext context) {
		final ColorScheme colorScheme = Theme.of(context).colorScheme;

		return Card(
			elevation: AppElevation.none,
			clipBehavior: Clip.antiAlias,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
			child: Padding(
				padding: const EdgeInsets.all(AppSpacing.lg),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Text(
							title,
							style: AppTypography.title.copyWith(color: colorScheme.onSurfaceVariant),
						),
						const SizedBox(height: AppSpacing.md),
						Text(
							value,
							style: AppTypography.headline.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w700),
						),
					],
				),
			),
		);
	}
}

class _UpcomingPaymentsCard extends StatelessWidget {
	const _UpcomingPaymentsCard();

	@override
	Widget build(BuildContext context) {
		return Card(
			elevation: AppElevation.none,
			clipBehavior: Clip.antiAlias,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
			child: Padding(
				padding: const EdgeInsets.all(AppSpacing.lg),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Text(
							'Upcoming Payments',
							style: AppTypography.title.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700),
						),
						const SizedBox(height: AppSpacing.md),
						Text(
							'No payments scheduled.',
							style: AppTypography.body.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
						),
					],
				),
			),
		);
	}
}

class _QuickActionsSection extends StatelessWidget {
	const _QuickActionsSection();

	@override
	Widget build(BuildContext context) {
		return Wrap(
			runSpacing: AppSpacing.sm,
			spacing: AppSpacing.sm,
			children: const <Widget>[
				_QuickActionButton(label: 'Add Income'),
				_QuickActionButton(label: 'Add Debt'),
				_QuickActionButton(label: 'Register Payment'),
			],
		);
	}
}

class _QuickActionButton extends StatelessWidget {
	const _QuickActionButton({required this.label});

	final String label;

	@override
	Widget build(BuildContext context) {
		return ElevatedButton(
			onPressed: () {},
			style: ElevatedButton.styleFrom(
				backgroundColor: Theme.of(context).colorScheme.primary,
				foregroundColor: Theme.of(context).colorScheme.onPrimary,
			),
			child: Text(label),
		);
	}
}