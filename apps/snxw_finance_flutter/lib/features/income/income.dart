import 'package:flutter/material.dart';

class IncomePage extends StatelessWidget {
	const IncomePage({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Income'),
			),
			body: Center(
				child: Text('Income'),
			),
		);
	}
}