import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard.dart';
import '../features/cash_accounts/cash_accounts.dart';
import '../features/debts/debts.dart';
import '../features/expenses/expenses.dart';
import '../features/goals/goals.dart';
import '../features/income/income.dart';
import '../features/payments/payments.dart';
import '../features/settings/settings.dart';

final GoRouter appRouter = GoRouter(
	routes: <RouteBase>[
		GoRoute(
			path: '/',
			builder: (BuildContext context, GoRouterState state) => const DashboardPage(),
		),
		GoRoute(
			path: '/income',
			builder: (BuildContext context, GoRouterState state) => const IncomePage(),
		),
		GoRoute(
			path: '/cash-accounts',
			builder: (BuildContext context, GoRouterState state) => const CashAccountsPage(),
		),
		GoRoute(
			path: '/expenses',
			builder: (BuildContext context, GoRouterState state) => const ExpensesPage(),
		),
		GoRoute(
			path: '/debts',
			builder: (BuildContext context, GoRouterState state) => const DebtsPage(),
		),
		GoRoute(
			path: '/goals',
			builder: (BuildContext context, GoRouterState state) => const GoalsPage(),
		),
		GoRoute(
			path: '/payments',
			builder: (BuildContext context, GoRouterState state) => const PaymentsPage(),
		),
		GoRoute(
			path: '/settings',
			builder: (BuildContext context, GoRouterState state) => const SettingsPage(),
		),
	],
);