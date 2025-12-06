import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for login screen UI components
void main() {
  group('Login Form Widget Tests', () {
    testWidgets('Email field should accept input', (WidgetTester tester) async {
      final emailController = TextEditingController();
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: emailController,
            key: const Key('email_field'),
            decoration: const InputDecoration(labelText: 'Email'),
          ),
        ),
      ));
      
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      expect(emailController.text, 'test@example.com');
    });
    
    testWidgets('Password field should accept input and obscure text', (WidgetTester tester) async {
      final passwordController = TextEditingController();
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: passwordController,
            obscureText: true,
            key: const Key('password_field'),
            decoration: const InputDecoration(labelText: 'Password'),
          ),
        ),
      ));
      
      await tester.enterText(find.byKey(const Key('password_field')), 'SecurePass123');
      expect(passwordController.text, 'SecurePass123');
      
      // Verify the text is obscured
      final TextField textField = tester.widget(find.byKey(const Key('password_field')));
      expect(textField.obscureText, true);
    });
    
    testWidgets('Login button should be present and tappable', (WidgetTester tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            key: const Key('login_button'),
            onPressed: () => buttonPressed = true,
            child: const Text('Login'),
          ),
        ),
      ));
      
      expect(find.byKey(const Key('login_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('login_button')));
      expect(buttonPressed, true);
    });
  });
  
  group('Form Validation Widget Tests', () {
    testWidgets('Form validation should work', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('required_field'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  key: const Key('submit_button'),
                  onPressed: () => formKey.currentState?.validate(),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));
      
      // Submit without entering text
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pump();
      
      // Should show validation error
      expect(find.text('This field is required'), findsOneWidget);
    });
    
    testWidgets('Form should pass validation when filled', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('text_field'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  key: const Key('submit'),
                  onPressed: () => formKey.currentState?.validate(),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));
      
      // Enter text and submit
      await tester.enterText(find.byKey(const Key('text_field')), 'Valid input');
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pump();
      
      // Should not show validation error
      expect(find.text('Required'), findsNothing);
    });
  });
  
  group('Loading State Widget Tests', () {
    testWidgets('CircularProgressIndicator should display during loading', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('Button should be disabled during loading', (WidgetTester tester) async {
      bool isLoading = true;
      
      await tester.pumpWidget(MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: isLoading ? null : () {},
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            );
          },
        ),
      ));
      
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull); // Button should be disabled
    });
  });
  
  group('Marketplace Card Widget Tests', () {
    testWidgets('Marketplace card should display material info', (WidgetTester tester) async {
      const materialType = 'PLASTIC';
      const weight = '10 kg';
      const price = 'Rs. 500';
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Card(
            child: Column(
              children: [
                Text(materialType, key: const Key('material_type')),
                Text(weight, key: const Key('weight')),
                Text(price, key: const Key('price')),
              ],
            ),
          ),
        ),
      ));
      
      expect(find.text(materialType), findsOneWidget);
      expect(find.text(weight), findsOneWidget);
      expect(find.text(price), findsOneWidget);
    });
  });
  
  group('Theme Tests', () {
    testWidgets('App should support light theme', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.light(),
        home: const Scaffold(body: Text('Light Theme')),
      ));
      
      final context = tester.element(find.text('Light Theme'));
      expect(Theme.of(context).brightness, Brightness.light);
    });
    
    testWidgets('App should support dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(body: Text('Dark Theme')),
      ));
      
      final context = tester.element(find.text('Dark Theme'));
      expect(Theme.of(context).brightness, Brightness.dark);
    });
  });
}
