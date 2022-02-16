import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';

import 'package:h3_flutter/h3_flutter.dart';
import 'package:h3_flutter/internal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final lib = DynamicLibrary.open('c/h3lib/build/libh3lib.dylib');
  setUpAll(() {
    initH3C(lib);
  });
  test('h3ToFeature', () async {
    const hexagon = 0x89283082837ffff;
    final coordinates = h3.h3ToGeoBoundary(hexagon);
    coordinates.add(coordinates.first); // close loop
    final feature = {
      'id': hexagon,
      'type': 'Feature',
      'properties': {},
      'geometry': {
        'type': 'Polygon',
        'coordinates': [
          [
            for (final coordinate in coordinates)
              [coordinate.lon, coordinate.lat]
          ],
        ],
      }
    };

    expect(
      geojson2H3.h3ToFeature(hexagon),
      feature,
      reason: 'h3ToFeature matches expected',
    );
  });
  test('h3SetToFeatureCollection', () async {
    const hexagons = [0x89283085507ffff, 0x892830855b3ffff, 0x85283473fffffff];
    const properties = {
      0x89283085507ffff: {'foo': 1},
      0x892830855b3ffff: {'bar': 'baz'},
    };

    final result = geojson2H3.h3SetToFeatureCollection(
      hexagons,
      properties: (h3) => properties[h3],
    );

    expect(
      result['features'][0]['properties'],
      properties[hexagons[0]],
      reason: 'Properties match expected for hexagon',
    );

    expect(
      result['features'][1]['properties'],
      properties[hexagons[1]],
      reason: 'Properties match expected for hexagon',
    );

    expect(
      result['features'][2]['properties'],
      {},
      reason: 'Null property resolved to {}',
    );
  });
}
