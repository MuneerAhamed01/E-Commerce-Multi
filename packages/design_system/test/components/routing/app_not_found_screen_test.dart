import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('renders title and invokes onGoHome', (tester) async {
    var tapped = false;
    await pumpApp(tester, AppNotFoundScreen(onGoHome: () => tapped = true));

    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go home'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
