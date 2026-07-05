import 'package:flutter_test/flutter_test.dart';
import 'package:recyconnect/presentation/screens/individual/browse_marketplace_screen.dart';

void main() {
  group('BrowseMarketplaceScreen Constructor Tests', () {
    testWidgets('BrowseMarketplaceScreen accepts initialMapView and other parameters', (WidgetTester tester) async {
      const screen = BrowseMarketplaceScreen(
        initialMapView: true,
        initialMaterial: 'plastic',
        initialRadius: 'Within 10 km',
        initialSort: 'Nearest First',
      );

      expect(screen.initialMapView, true);
      expect(screen.initialMaterial, 'plastic');
      expect(screen.initialRadius, 'Within 10 km');
      expect(screen.initialSort, 'Nearest First');
    });

    testWidgets('BrowseMarketplaceScreen defaults initialMapView to false', (WidgetTester tester) async {
      const screen = BrowseMarketplaceScreen();

      expect(screen.initialMapView, false);
      expect(screen.initialMaterial, isNull);
      expect(screen.initialRadius, isNull);
      expect(screen.initialSort, isNull);
    });
  });
}
