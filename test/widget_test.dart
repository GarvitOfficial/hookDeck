import 'package:flutter_test/flutter_test.dart';
import 'package:hookdeck/main.dart';
import 'package:hookdeck/theme/theme_provider.dart';
import 'package:hookdeck/services/storage_service.dart';

void main() {
  testWidgets('HookDeck app smoke test', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    final storageService = StorageService();

    await tester.pumpWidget(HookDeckApp(
      themeProvider: themeProvider,
      storageService: storageService,
    ));

    expect(find.text('HookDeck'), findsOneWidget);
  });
}
