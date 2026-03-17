// This is a basic Flutter widget test.
//
// For more information about Flutter testing, read the 'Testing' documentation
// at https://flutter.dev/docs/testing

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:split_bill_app/main.dart';

void main() {
  testWidgets('App initializes', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AplicacionDividirGastos());

    // Verify that the home screen appears
    expect(find.text('Dividir Gastos'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
