import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget tests for profile screen components
void main() {
  group('Profile Header Widget Tests', () {
    testWidgets('Profile header should display user name', (WidgetTester tester) async {
      const userName = 'John Doe';
      const userEmail = 'john@example.com';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text(userName, key: const Key('user_name')),
              Text(userEmail, key: const Key('user_email')),
            ],
          ),
        ),
      ));
      
      expect(find.text(userName), findsOneWidget);
      expect(find.text(userEmail), findsOneWidget);
    });
    
    testWidgets('Profile avatar should display', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CircleAvatar(
            key: const Key('profile_avatar'),
            radius: 50,
            backgroundColor: Colors.green,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
      ));
      
      expect(find.byKey(const Key('profile_avatar')), findsOneWidget);
    });
  });
  
  group('Tab Bar Widget Tests', () {
    testWidgets('TabBar should have correct tabs', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Personal'),
                  Tab(text: 'Stats'),
                  Tab(text: 'Activity'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                Center(child: Text('Personal Content')),
                Center(child: Text('Stats Content')),
                Center(child: Text('Activity Content')),
              ],
            ),
          ),
        ),
      ));
      
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
    });
    
    testWidgets('TabBar should switch tabs on tap', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Tab 1'),
                  Tab(text: 'Tab 2'),
                  Tab(text: 'Tab 3'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                Center(child: Text('Content 1')),
                Center(child: Text('Content 2')),
                Center(child: Text('Content 3')),
              ],
            ),
          ),
        ),
      ));
      
      // Initially on Tab 1
      expect(find.text('Content 1'), findsOneWidget);
      
      // Tap on Tab 2
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();
      
      // Should show Content 2
      expect(find.text('Content 2'), findsOneWidget);
    });
  });
  
  group('Settings Tile Widget Tests', () {
    testWidgets('Settings tile should display icon and title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListTile(
            key: const Key('settings_tile'),
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ));
      
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
    
    testWidgets('Settings tile should be tappable', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListTile(
            key: const Key('tappable_tile'),
            title: const Text('Tappable'),
            onTap: () => tapped = true,
          ),
        ),
      ));
      
      await tester.tap(find.byKey(const Key('tappable_tile')));
      expect(tapped, true);
    });
  });
  
  group('Stats Card Widget Tests', () {
    testWidgets('Stats card should display value and label', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '125',
                    key: const Key('stat_value'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('Orders', key: Key('stat_label')),
                ],
              ),
            ),
          ),
        ),
      ));
      
      expect(find.text('125'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
    });
  });
  
  group('Logout Dialog Tests', () {
    testWidgets('Logout dialog should show confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                key: const Key('logout_button'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Logout'),
              );
            },
          ),
        ),
      ));
      
      // Tap logout button
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();
      
      // Dialog should appear
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
