// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tetris_weather/main.dart';

void main() {
  testWidgets('晴天主视图加载', (WidgetTester tester) async {
    await tester.pumpWidget(const TetrisWeatherApp());

    expect(find.text('莫斯科'), findsOneWidget);
    expect(find.textContaining('晴朗'), findsWidgets);
    expect(find.byType(TetrisBoard), findsOneWidget);
  });
}
