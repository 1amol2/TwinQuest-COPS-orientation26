import 'package:flutter_test/flutter_test.dart';
import 'package:pairquest/main.dart';


void main() {
  testWidgets('PairQuest home screen renders', (tester) async {
    await tester.pumpWidget(const PairQuestApp());
    expect(find.text('PairQuest'), findsOneWidget);
    expect(find.text('Join Event'), findsOneWidget);
    expect(find.text('How it works?'), findsOneWidget);
  });
}
