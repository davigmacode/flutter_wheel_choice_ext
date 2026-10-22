import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  group('WheelCascadeController & Choice', () {
    final sampleTree = [
      const WheelCascadeItem<String>(
        value: 'USA',
        label: 'United States',
        children: [
          WheelCascadeItem(
            value: 'CA',
            label: 'California',
            children: [
              WheelCascadeItem(value: 'LA', label: 'Los Angeles'),
              WheelCascadeItem(value: 'SF', label: 'San Francisco'),
            ],
          ),
          WheelCascadeItem(
            value: 'NY',
            label: 'New York',
            children: [
              WheelCascadeItem(value: 'NYC', label: 'New York City'),
              WheelCascadeItem(value: 'BUF', label: 'Buffalo'),
            ],
          ),
        ],
      ),
      const WheelCascadeItem<String>(
        value: 'ID',
        label: 'Indonesia',
        children: [
          WheelCascadeItem(
            value: 'JKT',
            label: 'Jakarta',
            children: [
              WheelCascadeItem(value: 'JS', label: 'Jakarta Selatan'),
              WheelCascadeItem(value: 'JP', label: 'Jakarta Pusat'),
            ],
          ),
        ],
      ),
    ];

    test('initializes and calculates depth correctly', () {
      final controller = WheelCascadeController<String>(items: sampleTree);

      expect(controller.depth, equals(3));
      expect(controller.value, equals(['USA', 'CA', 'LA']));
      expect(controller.controllers.length, equals(3));

      controller.dispose();
    });

    test('cascades downstream options when level 0 changes', () {
      final controller = WheelCascadeController<String>(items: sampleTree);

      // Change level 0 to 'ID'
      controller.controllers[0].jumpToValue('ID');

      expect(controller.value[0], equals('ID'));
      expect(controller.value[1], equals('JKT'));
      expect(controller.value[2], equals('JS'));

      controller.dispose();
    });

    test('supports async optionsLoader and resolves downstream values', () async {
      final completer = Completer<List<WheelCascadeItem<String>>>();

      final controller = WheelCascadeController<String>(
        depth: 2,
        optionsLoader: (level, selected) {
          if (level == 0) {
            return const [
              WheelCascadeItem(value: 'fruits', label: 'Fruits'),
              WheelCascadeItem(value: 'veggies', label: 'Vegetables'),
            ];
          }
          // Level 1 is async
          return completer.future;
        },
      );

      // Level 0 is loaded immediately
      expect(controller.value[0], equals('fruits'));
      // Level 1 is loading
      expect(controller.isLoading(1), isTrue);

      completer.complete(const [
        WheelCascadeItem(value: 'apple', label: 'Apple'),
        WheelCascadeItem(value: 'banana', label: 'Banana'),
      ]);

      await Future<void>.delayed(Duration.zero);

      expect(controller.isLoading(1), isFalse);
      expect(controller.value, equals(['fruits', 'apple']));

      controller.dispose();
    });

    testWidgets('WheelCascadeChoice updates downstream options in UI on level change',
        (tester) async {
      final controller = WheelCascadeController<String>(items: sampleTree);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WheelCascadeChoice<String>.raw(controller: controller),
            ),
          ),
        ),
      );

      expect(find.byType(WheelChoice<String>), findsNWidgets(3));
      // Initially displays United States, California, Los Angeles
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('California'), findsOneWidget);
      expect(find.text('Los Angeles'), findsOneWidget);

      // Change level 0 to ID
      controller.controllers[0].jumpToValue('ID');
      await tester.pumpAndSettle();

      // Downstream should now show Jakarta and Jakarta Selatan
      expect(find.text('Indonesia'), findsOneWidget);
      expect(find.text('Jakarta'), findsOneWidget);
      expect(find.text('Jakarta Selatan'), findsOneWidget);
      // Old downstream choices should be gone from the widget tree
      expect(find.text('California'), findsNothing);
      expect(find.text('Los Angeles'), findsNothing);

      controller.dispose();
    });

    testWidgets('WheelCascadeChoiceFormField validates selection', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: WheelCascadeChoiceFormField<String>(
                items: sampleTree,
                validator: (val) {
                  if (val != null && val.contains('ID')) {
                    return 'USA shipping addresses only';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Default is USA -> valid
      expect(formKey.currentState!.validate(), isTrue);
    });
  });
}
