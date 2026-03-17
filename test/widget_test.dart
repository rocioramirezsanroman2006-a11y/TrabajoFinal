import 'package:flutter_test/flutter_test.dart';
import 'package:split_bill_app/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const AplicacionDividirGastos());
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}
