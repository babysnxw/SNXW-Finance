import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database_provider.dart';
import '../../core/repositories/expense_repository.dart';
import '../../core/repositories/income_repository.dart';
import '../../shared/design/design.dart';
import '../../shared/models/models.dart';

final FutureProvider<DashboardMetrics> dashboardMetricsProvider = FutureProvider<DashboardMetrics>(
  (ref) async {
    final IncomeRepository incomeRepository = IncomeRepository(await ref.watch(isarProvider.future));
    final ExpenseRepository expenseRepository = ExpenseRepository(await ref.watch(isarProvider.future));

    final List<Income> incomes = await incomeRepository.list();
    final List<Expense> expenses = await expenseRepository.list();

    final double totalIncome = incomes.fold<double>(0, (double total, Income income) => total + income.amount);
    final double totalExpenses = expenses.fold<double>(0, (double total, Expense expense) => total + expense.amount);

    return DashboardMetrics(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netBalance: totalIncome - totalExpenses,
    );
  },
);

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardMetrics> metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNXW Finance'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _DashboardContent(metricsAsync: metricsAsync),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.metricsAsync});

  final AsyncValue<DashboardMetrics> metricsAsync;

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
            child: metricsAsync.when(
              data: (DashboardMetrics metrics) => SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(horizontalPadding, AppSpacing.xl, horizontalPadding, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const _GreetingSection(),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionHeader(title: 'Resumen Financiero'),
                    const SizedBox(height: AppSpacing.md),
                    _SummaryCardsGrid(columns: summaryColumns, metrics: metrics),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionHeader(title: 'Próximos Pagos'),
                    const SizedBox(height: AppSpacing.md),
                    const _UpcomingPaymentsCard(),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionHeader(title: 'Acciones Rápidas'),
                    const SizedBox(height: AppSpacing.md),
                    const _QuickActionsSection(),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stackTrace) => Center(
                child: Text(
                  'Error al cargar los datos: $error',
                  style: AppTypography.body.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
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
          _getGreeting(),
          style: AppTypography.title.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Así va tu dinero hoy.',
          style: AppTypography.display.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '¡Buenos días! 👋';
    } else if (hour < 18) {
      return '¡Buenas tardes! 👋';
    } else {
      return '¡Buenas noches! 👋';
    }
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
  const _SummaryCardsGrid({required this.columns, required this.metrics});

  final int columns;
  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final List<_SummaryCardData> items = <_SummaryCardData>[
      _SummaryCardData(
        title: 'Disponible',
        value: _formatCurrency(metrics.netBalance),
        color: Colors.blue,
        icon: Icons.account_balance_wallet_rounded,
      ),
      _SummaryCardData(
        title: 'Ingresos',
        value: _formatCurrency(metrics.totalIncome),
        color: Colors.green,
        icon: Icons.trending_up_rounded,
      ),
      _SummaryCardData(
        title: 'Gastos',
        value: _formatCurrency(metrics.totalExpenses),
        color: Colors.red,
        icon: Icons.trending_down_rounded,
      ),
    ];

    return Wrap(
      runSpacing: AppSpacing.md,
      spacing: AppSpacing.md,
      children: items
        .map(
          (_SummaryCardData item) => SizedBox(
            width: _cardWidthForColumns(context, columns),
            child: _SummaryCard(
              title: item.title,
              value: item.value,
              color: item.color,
              icon: item.icon,
            ),
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

class DashboardMetrics {
  const DashboardMetrics({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netBalance,
  });

  final double totalIncome;
  final double totalExpenses;
  final double netBalance;
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTypography.title.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTypography.headline.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
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
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.credit_card_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Próximos pagos',
                  style: AppTypography.title.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade400,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'No tienes pagos pendientes.',
                  style: AppTypography.body.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
      children: <Widget>[
        _QuickActionButton(
          label: 'Ingresos',
          icon: Icons.trending_up_rounded,
          route: '/income',
          color: Colors.green,
        ),
        _QuickActionButton(
          label: 'Gastos',
          icon: Icons.trending_down_rounded,
          route: '/expenses',
          color: Colors.red,
        ),
        _QuickActionButton(
          label: 'Cuentas',
          icon: Icons.account_balance_wallet_rounded,
          route: '/cash-accounts',
          color: Colors.purple,
        ),
        _QuickActionButton(
          label: 'Deudas',
          icon: Icons.credit_card_rounded,
          route: '/debts',
          color: Colors.orange,
        ),
        _QuickActionButton(
          label: 'Metas',
          icon: Icons.flag_rounded,
          route: '/goals',
          color: Colors.blue,
        ),
        _QuickActionButton(
          label: 'Pagos',
          icon: Icons.payment_rounded,
          route: '/payments',
          color: Colors.teal,
        ),
        _QuickActionButton(
          label: 'Configuración',
          icon: Icons.settings_rounded,
          route: '/settings',
          color: Colors.grey,
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.route,
    required this.color,
  });

  final String label;
  final IconData icon;
  final String route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () => context.go(route),
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCurrency(double value) {
  return '\$${value.toStringAsFixed(2)}';
}