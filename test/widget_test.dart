import 'package:flutter_test/flutter_test.dart';

import 'package:ultrasound_app/app.dart';

void main() {
  testWidgets('Upload screen renders primary actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const UltrasoundApp());

    expect(find.text('SonoBowel'), findsOneWidget);
    expect(find.text('Выбрать из галереи'), findsOneWidget);
    expect(find.text('Сделать фото'), findsOneWidget);
  });
}
