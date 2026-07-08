import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database_provider.dart';
import '../../core/repositories/expense_repository.dart';
import '../../core/repositories/income_repository.dart';
import '../../shared/design/design.dart';
import '../../shared/models/models.dart';
import '../income/income.dart';
import '../expenses/expenses.dart';
import '../debts/debts.dart';
import '../goals/goals.dart';

// ============================================================
// 1. PROVIDERS
// ============================================================

final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final incomeRepository = IncomeRepository(await ref.watch(isarProvider.future));
  final expenseRepository = ExpenseRepository(await ref.watch(isarProvider.future));

  final incomes = await incomeRepository.list();
  final expenses = await expenseRepository.list();

  final double totalIncome = incomes.fold<double>(0, (total, income) => total + income.amount);
  final double totalExpenses = expenses.fold<double>(0, (total, expense) => total + expense.amount);

  return DashboardMetrics(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netBalance: totalIncome - totalExpenses,
  );
});

final financialAdvisorProvider = Provider<FinancialAdvisor>((ref) {
  final incomes = ref.watch(incomesProvider).valueOrNull ?? [];
  final expenses = ref.watch(expensesProvider).valueOrNull ?? [];
  final debts = ref.watch(debtsProvider).valueOrNull ?? [];
  final goals = ref.watch(goalsProvider).valueOrNull ?? [];

  final isMonthly = true;

  return FinancialAdvisor(
    incomes: incomes,
    expenses: expenses,
    debts: debts,
    goals: goals,
    isMonthlyView: isMonthly,
  );
});

// ============================================================
// 2. MODELO DEL ASESOR FINANCIERO
// ============================================================

class FinancialAdvisor {
  final List<Income> incomes;
  final List<Expense> expenses;
  final List<Debt> debts;
  final List<FinancialGoal> goals;
  final bool isMonthlyView;

  FinancialAdvisor({
    required this.incomes,
    required this.expenses,
    required this.debts,
    required this.goals,
    this.isMonthlyView = true,
  });

  double get totalMonthlyIncome {
    final multiplier = isMonthlyView ? 1.0 : 4.33;
    return incomes.fold<double>(0.0, (sum, i) => sum + i.amount) * multiplier;
  }

  double get totalMonthlyExpenses {
    final multiplier = isMonthlyView ? 1.0 : 4.33;
    return expenses.fold<double>(0.0, (sum, e) => sum + e.amount) * multiplier;
  }

  double get freeCashFlow {
    return totalMonthlyIncome - totalMonthlyExpenses;
  }

  double get totalDebt {
    return debts.fold<double>(0.0, (sum, d) => sum + d.outstandingBalance);
  }

  List<Debt> get prioritizedDebts {
    final sorted = List<Debt>.from(debts)
      ..sort((a, b) {
        final interestCompare = b.interestRate.compareTo(a.interestRate);
        if (interestCompare != 0) return interestCompare;
        return a.outstandingBalance.compareTo(b.outstandingBalance);
      });
    return sorted;
  }

  Map<String, dynamic> get paymentPlan {
    final plan = <String, dynamic>{};
    final sorted = prioritizedDebts;
    double remaining = freeCashFlow > 0 ? freeCashFlow : 0;

    for (var debt in sorted) {
      if (remaining <= 0) break;
      
      final recommended = (remaining * 0.7).clamp(debt.minimumPayment, debt.outstandingBalance);
      final actualPayment = recommended > debt.outstandingBalance 
          ? debt.outstandingBalance 
          : recommended;
      
      plan[debt.name] = {
        'payment': actualPayment,
        'interestRate': debt.interestRate,
        'remainingBalance': debt.outstandingBalance - actualPayment,
        'outstandingBalance': debt.outstandingBalance,
        'minimumPayment': debt.minimumPayment,
        'priority': sorted.indexOf(debt) + 1,
        'monthsToPay': _calculateMonthsToPay(debt, actualPayment),
      };
      
      remaining -= actualPayment;
    }

    return plan;
  }

  int _calculateMonthsToPay(Debt debt, double monthlyPayment) {
    if (monthlyPayment <= 0 || debt.outstandingBalance <= 0) return 0;
    return (debt.outstandingBalance / monthlyPayment).ceil();
  }

  int get totalMonthsToPayOff {
    if (freeCashFlow <= 0 || totalDebt <= 0) return 0;
    
    double remainingDebt = totalDebt;
    double monthlyPayment = freeCashFlow * 0.7;
    int months = 0;
    
    while (remainingDebt > 0 && months < 120) {
      remainingDebt -= monthlyPayment;
      months++;
    }
    
    return months;
  }

  String get advice {
    if (incomes.isEmpty) {
      return '📝 Registra tus ingresos para recibir asesoría personalizada.';
    }
    
    if (freeCashFlow < 0) {
      return '🚨 Tus gastos superan tus ingresos en \$${(-freeCashFlow).toStringAsFixed(0)}/mes. ¡Revisa tus gastos urgentemente!';
    }
    
    if (totalDebt == 0) {
      return '🎉 ¡Sin deudas! Increíble, enfócate en tus metas de ahorro.';
    }
    
    final monthsToPay = totalMonthsToPayOff;
    if (monthsToPay <= 3) {
      return '💪 ¡Vas excelente! Puedes pagar todas tus deudas en $monthsToPay meses si sigues el plan.';
    } else if (monthsToPay <= 6) {
      return '📊 Tienes un plan claro. Pagarás todo en $monthsToPay meses. ¡Sigue así!';
    } else if (monthsToPay <= 12) {
      return '⏳ Te tomará $monthsToPay meses pagar todo. Considera aumentar tus ingresos o reducir gastos.';
    } else {
      return '⚠️ Te tomará $monthsToPay meses pagar todo. Prioriza la deuda con mayor interés (${prioritizedDebts.first.interestRate}%).';
    }
  }

  String get detailedAdvice {
    if (debts.isEmpty) return '🎉 No tienes deudas. ¡Felicidades!';
    
    final prioritized = prioritizedDebts;
    final first = prioritized.first;
    final last = prioritized.last;
    
    return '🎯 Prioridad: Pagar primero "${first.name}" (${first.interestRate}% de interés). '
           'Es tu deuda más costosa. '
           'Luego sigue con "${last.name}" (${last.interestRate}%).';
  }

  String get motivationMessage {
    if (goals.isEmpty) return '🎯 Crea una meta financiera para mantenerte motivado.';
    
    final goal = goals.first;
    final progress = goal.currentAmount / goal.targetAmount;
    
    if (progress >= 0.75) {
      return '🏆 ¡Estás a punto de lograrlo! ${(progress * 100).toStringAsFixed(0)}% de "${goal.name}". ¡El final está cerca!';
    } else if (progress >= 0.5) {
      return '🎉 ¡Vas excelente! ${(progress * 100).toStringAsFixed(0)}% de "${goal.name}". Sigue así, ya pasaste la mitad.';
    } else if (progress >= 0.25) {
      return '💪 Buen inicio. ${(progress * 100).toStringAsFixed(0)}% de "${goal.name}". Cada paso cuenta, ¡no te rindas!';
    } else {
      return '🚀 ¡Comienza hoy! "${goal.name}" te espera. ${(progress * 100).toStringAsFixed(0)}% es solo el principio.';
    }
  }

  String get monthlySummary {
    if (incomes.isEmpty) return '📝 Registra tus ingresos para ver tu resumen.';
    
    final freeCash = freeCashFlow;
    final debtTotal = totalDebt;

    if (freeCash > 0 && debtTotal > 0) {
      final monthsToPay = totalMonthsToPayOff;
      return '💰 Te sobran \$${freeCash.toStringAsFixed(0)} al mes. '
             'Puedes pagar \$${(freeCash * 0.7).toStringAsFixed(0)} de deudas '
             'y ahorrar \$${(freeCash * 0.3).toStringAsFixed(0)}. '
             '⏳ Tiempo estimado para pagar todo: $monthsToPay meses.';
    } else if (freeCash > 0 && debtTotal == 0) {
      return '💰 Te sobran \$${freeCash.toStringAsFixed(0)} al mes. '
             '¡Aprovecha para ahorrar o invertir!';
    } else {
      return '⚠️ Tus gastos son mayores que tus ingresos. '
             'Revisa tus gastos y busca reducir \$${(-freeCash).toStringAsFixed(0)} mensuales.';
    }
  }

  String get availabilityProjection {
    if (incomes.isEmpty) return '📝 Registra tus ingresos para ver proyecciones.';
    
    final current = freeCashFlow;
    final debtCount = debts.length;
    
    if (debtCount == 0) {
      return '💰 Disponible actual: \$${current.toStringAsFixed(0)}. '
             'El próximo mes tendrás lo mismo (sin deudas).';
    }
    
    final monthsToPay = totalMonthsToPayOff;
    return '📊 Este mes dispones de \$${current.toStringAsFixed(0)}. '
           'Mantén el ritmo, pagarás tu primera deuda en $monthsToPay meses.';
  }
}

// ============================================================
// 3. DASHBOARD PRINCIPAL
// ============================================================

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final advisor = ref.watch(financialAdvisorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SNXW Finance'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dashboardMetricsProvider);
              ref.invalidate(incomesProvider);
              ref.invalidate(expensesProvider);
              ref.invalidate(debtsProvider);
              ref.invalidate(goalsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardMetricsProvider);
            ref.invalidate(incomesProvider);
            ref.invalidate(expensesProvider);
            ref.invalidate(debtsProvider);
            ref.invalidate(goalsProvider);
          },
          child: metricsAsync.when(
            data: (metrics) => SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _GreetingSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _FinancialAdvisorCard(advisor: advisor),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionHeader(title: 'Resumen Financiero'),
                  const SizedBox(height: AppSpacing.md),
                  _SummaryCardsGrid(metrics: metrics),
                  const SizedBox(height: AppSpacing.xl),
                  const _ExpenseSimulatorCard(),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeader(title: 'Tus Deudas'),
                  const SizedBox(height: AppSpacing.md),
                  const _DebtListCard(),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeader(title: '🎯 Tus Metas'),
                  const SizedBox(height: AppSpacing.md),
                  const _MotivationalGoalsCard(),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeader(title: 'Acciones Rápidas'),
                  const SizedBox(height: AppSpacing.md),
                  const _QuickActionsSection(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Error al cargar los datos',
                    style: AppTypography.title.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(dashboardMetricsProvider);
                      ref.invalidate(incomesProvider);
                      ref.invalidate(expensesProvider);
                      ref.invalidate(debtsProvider);
                      ref.invalidate(goalsProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 4. SALUDO
// ============================================================

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: AppTypography.title.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
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
    if (hour < 12) return '¡Buenos días! 👋';
    if (hour < 18) return '¡Buenas tardes! 👋';
    return '¡Buenas noches! 👋';
  }
}

// ============================================================
// 5. HEADER DE SECCIONES
// ============================================================

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

// ============================================================
// 6. ASESOR FINANCIERO (CARD)
// ============================================================

class _FinancialAdvisorCard extends StatelessWidget {
  const _FinancialAdvisorCard({required this.advisor});

  final FinancialAdvisor advisor;

  @override
  Widget build(BuildContext context) {
    final hasData = advisor.incomes.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_rounded, color: Colors.blue),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Asesor Financiero',
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              advisor.monthlySummary,
              style: AppTypography.body.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _getAdviceColor(advisor.advice).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    _getAdviceIcon(advisor.advice),
                    color: _getAdviceColor(advisor.advice),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      advisor.advice,
                      style: AppTypography.body.copyWith(
                        color: _getAdviceColor(advisor.advice),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasData) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  advisor.availabilityProjection,
                  style: AppTypography.body.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            if (advisor.debts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                '🎯 Orden de pago recomendado:',
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...advisor.prioritizedDebts.asMap().entries.map((entry) {
                final index = entry.key;
                final debt = entry.value;
                final plan = advisor.paymentPlan[debt.name] as Map<String, dynamic>?;
                final payment = plan?['payment'] ?? 0;
                final months = plan?['monthsToPay'] ?? 0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(index).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTypography.label.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(index),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              debt.name,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${debt.interestRate}% interés • ${debt.outstandingBalance.toStringAsFixed(0)} pendiente',
                              style: AppTypography.label.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${payment.toStringAsFixed(0)}',
                            style: AppTypography.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            '$months meses',
                            style: AppTypography.label.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (hasData && advisor.goals.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        advisor.motivationMessage,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getAdviceColor(String advice) {
    if (advice.contains('🚨')) return Colors.red;
    if (advice.contains('🎉')) return Colors.green;
    if (advice.contains('💪')) return Colors.blue;
    if (advice.contains('⏳')) return Colors.orange;
    return Colors.grey;
  }

  IconData _getAdviceIcon(String advice) {
    if (advice.contains('🚨')) return Icons.warning_rounded;
    if (advice.contains('🎉')) return Icons.emoji_events_rounded;
    if (advice.contains('💪')) return Icons.fitness_center_rounded;
    if (advice.contains('⏳')) return Icons.timer_rounded;
    return Icons.info_rounded;
  }

  Color _getPriorityColor(int index) {
    final colors = [Colors.red, Colors.orange, Colors.amber, Colors.blue, Colors.green];
    return colors[index % colors.length];
  }
}

// ============================================================
// 7. RESUMEN FINANCIERO
// ============================================================

class _SummaryCardsGrid extends StatelessWidget {
  const _SummaryCardsGrid({required this.metrics});

  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final items = [
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

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: _SummaryCard(
              title: item.title,
              value: item.value,
              color: item.color,
              icon: item.icon,
            ),
          ),
        );
      }).toList(),
    );
  }
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.label.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: AppTypography.headline.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 8. SIMULADOR DE GASTOS
// ============================================================

class _ExpenseSimulatorCard extends ConsumerStatefulWidget {
  const _ExpenseSimulatorCard();

  @override
  ConsumerState<_ExpenseSimulatorCard> createState() => _ExpenseSimulatorCardState();
}

class _ExpenseSimulatorCardState extends ConsumerState<_ExpenseSimulatorCard> {
  final _controller = TextEditingController();
  double _simulatedAmount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final advisor = ref.watch(financialAdvisorProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate_rounded, color: Colors.blue),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '🤔 Simulador: ¿Qué pasa si...?',
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Prueba cuánto impactaría un gasto extra en tus finanzas.',
              style: AppTypography.body.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '¿Cuánto quieres gastar?',
                hintText: 'Ej: 200',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _simulatedAmount = 0);
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _simulatedAmount = double.tryParse(value) ?? 0;
                });
              },
            ),
            if (_simulatedAmount > 0) ...[
              const SizedBox(height: AppSpacing.md),
              _buildImpactCard(
                advisor: advisor,
                amount: _simulatedAmount,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard({
    required FinancialAdvisor advisor,
    required double amount,
  }) {
    final newBalance = advisor.freeCashFlow - amount;
    final canAfford = newBalance >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: canAfford 
          ? Colors.green.withValues(alpha: 0.08) 
          : Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: canAfford ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                canAfford ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: canAfford ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                canAfford 
                  ? '✅ Puedes comprarlo sin problema'
                  : '⚠️ Te faltarían \$${(newBalance * -1).toStringAsFixed(2)}',
                style: AppTypography.title.copyWith(
                  color: canAfford ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            canAfford
              ? 'Después del gasto te sobrarían \$${newBalance.toStringAsFixed(2)} para el resto del mes.'
              : 'Considera si realmente necesitas este gasto ahora. Podrías esperar al próximo mes.',
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 9. DEUDAS SIMPLIFICADAS
// ============================================================

class _DebtListCard extends ConsumerWidget {
  const _DebtListCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider);
    final advisor = ref.watch(financialAdvisorProvider);

    return debtsAsync.when(
      data: (debts) {
        final activeDebts = debts.where((d) => d.status != 'Completada' && d.status != 'Pagada').toList();

        if (activeDebts.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade400),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '🎉 ¡Sin deudas! Sigue así.',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: activeDebts.map((debt) {
                final progress = debt.outstandingBalance / debt.principal;
                final plan = advisor.paymentPlan[debt.name] as Map<String, dynamic>?;
                final strategy = plan?['payment'] ?? debt.minimumPayment;
                final monthsToPay = plan?['monthsToPay'] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              debt.name,
                              style: AppTypography.title.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '\$${debt.outstandingBalance.toStringAsFixed(0)}',
                            style: AppTypography.headline.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress.clamp(0, 1),
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              color: progress > 0.7 ? Colors.orange : Colors.blue,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: AppTypography.label.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pago mínimo: \$${debt.minimumPayment.toStringAsFixed(0)}',
                            style: AppTypography.label.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              '💡 Paga \$${strategy.toStringAsFixed(0)}',
                              style: AppTypography.label.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (monthsToPay > 0) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '⏳ ${monthsToPay == 1 ? '1 mes' : '$monthsToPay meses'} para pagar esta deuda',
                          style: AppTypography.label.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: SizedBox(
          height: 60,
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Error al cargar deudas',
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 10. METAS MOTIVADORAS
// ============================================================

class _MotivationalGoalsCard extends ConsumerWidget {
  const _MotivationalGoalsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final advisor = ref.watch(financialAdvisorProvider);

    return goalsAsync.when(
      data: (goals) {
        if (goals.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded, size: 48, color: Colors.amber),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '🎯 ¡Crea tu primera meta financiera!',
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Define un objetivo y comienza a trabajar en él hoy.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => context.go('/goals'),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Meta'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: goals.map((goal) {
                final progress = goal.currentAmount / goal.targetAmount;
                final isCompleted = progress >= 1;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: isCompleted 
                                ? Colors.green.withValues(alpha: 0.1) 
                                : Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Icon(
                              isCompleted ? Icons.emoji_events_rounded : Icons.flag_rounded,
                              color: isCompleted ? Colors.green : Colors.blue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              goal.name,
                              style: AppTypography.title.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                '🎉 Completada',
                                style: AppTypography.label.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress.clamp(0, 1),
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              color: isCompleted ? Colors.green : Colors.blue,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: AppTypography.label.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${goal.currentAmount.toStringAsFixed(0)} de \$${goal.targetAmount.toStringAsFixed(0)}',
                            style: AppTypography.label.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (!isCompleted && goals.isNotEmpty)
                            Text(
                              advisor.motivationMessage.split('"').last.replaceAll('"', ''),
                              style: AppTypography.label.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: SizedBox(
          height: 60,
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Error al cargar metas',
            style: AppTypography.body.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 11. ACCIONES RÁPIDAS
// ============================================================

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: AppSpacing.sm,
      spacing: AppSpacing.sm,
      children: [
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

// ============================================================
// 12. HELPERS Y UTILIDADES
// ============================================================

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

String _formatCurrency(double value) {
  return '\$${value.toStringAsFixed(2)}';
}