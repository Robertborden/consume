# Testing Helper for CONSUME

Help write and run tests for the CONSUME app.

## Test Structure

```
test/
├── unit/
│   ├── domain/           # Entity tests
│   ├── data/             # Model and datasource tests
│   └── core/             # Utility tests
├── widget/
│   └── presentation/     # Widget tests
└── integration/
    └── flows/            # Full flow tests
```

## Testing Libraries

- `flutter_test` - Core testing
- `mocktail` - Mocking
- `fake_async` - Time-based tests

## Test Patterns

### Unit Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:consume/domain/entities/saved_item.dart';

void main() {
  group('SavedItem', () {
    test('should calculate isExpired correctly', () {
      final item = SavedItem(
        // ... properties
        expiresAt: DateTime.now().subtract(Duration(days: 1)),
      );
      
      expect(item.isExpired, isTrue);
    });
  });
}
```

### Widget Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:consume/presentation/widgets/item_card.dart';

void main() {
  testWidgets('ItemCard displays title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ItemCard(item: testItem),
        ),
      ),
    );
    
    expect(find.text('Test Title'), findsOneWidget);
  });
}
```

### Provider Test Template
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDataSource extends Mock implements SavedItemsRemoteDataSource {}

void main() {
  late MockDataSource mockDataSource;
  late ProviderContainer container;
  
  setUp(() {
    mockDataSource = MockDataSource();
    container = ProviderContainer(
      overrides: [
        savedItemsDataSourceProvider.overrideWithValue(mockDataSource),
      ],
    );
  });
  
  tearDown(() => container.dispose());
});
```

## Testing Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific file
flutter test test/unit/domain/saved_item_test.dart

# Run with verbose output
flutter test --reporter expanded
```

## Current Task

$ARGUMENTS

Provide:
1. Test file structure and naming
2. Complete test code with assertions
3. Mock setup if needed
4. Edge cases to consider
5. Commands to run the tests
