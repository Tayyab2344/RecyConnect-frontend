import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:recyconnect/core/models/listing_model.dart';
import 'package:recyconnect/core/services/listing_service.dart';

void main() {
  test('Listing serialization test', () {
    // Create dummy base64 strings
    final base64String = base64Encode(List.generate(100, (i) => i));
    final images = [base64String, base64String, base64String];

    final listing = Listing(
      id: 0,
      userId: 1,
      materialType: 'plastic',
      estimatedWeight: 5.0,
      pickupAddress: 'Test Address',
      status: 'PENDING',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: images,
    );

    // Test toCreateJson
    final jsonMap = listing.toCreateJson();
    expect(jsonMap['images'], isA<List<String>>());
    expect(jsonMap['images'].length, 3);
    expect(jsonMap['images'][0], base64String);

    // Test jsonEncode of the map (simulating ApiService)
    try {
      final jsonString = jsonEncode(jsonMap);
      print('Serialization successful: ${jsonString.substring(0, 100)}...');
    } catch (e) {
      fail('JSON encoding failed: $e');
    }
  });

  test('ListingService toCreateJson structure', () {
     final listing = Listing(
      id: 1,
      userId: 1,
      materialType: 'paper',
      estimatedWeight: 2.0,
      pickupAddress: '123 Fake St',
      status: 'PENDING',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: ['img1', 'img2'],
    );
    
    final map = listing.toCreateJson();
    expect(map.containsKey('images'), true);
    expect(map['images'], equals(['img1', 'img2']));
  });
}
