import 'package:flutter_test/flutter_test.dart';
import 'package:ride_together/core/app.dart';

void main() {
  testWidgets('shows the RideTogether foundation screen', (tester) async {
    await tester.pumpWidget(const RideTogetherApp());

    expect(find.text('RideTogether'), findsNWidgets(2));
    expect(find.text('Group travel safety and coordination'), findsOneWidget);
  });
}
