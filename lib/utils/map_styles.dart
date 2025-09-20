import 'package:flutter/foundation.dart';

class MapStyles {
  static const String mijiCustom = '''
  [
    // 夜色系：整體偏冷、淺紫灰，保持高對比
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#3C3458"}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#2F2C44"}]},
    {"featureType": "landscape.natural", "elementType": "geometry", "stylers": [{"color": "#3A3553"}]},
    {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#35324B"}]},
    {"featureType": "transit", "stylers": [{"visibility": "off"}]},
    {"featureType": "poi.business", "stylers": [{"visibility": "off"}]},
    {"featureType": "poi", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#D2CCE8"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#5A5671"}]},
    {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#EDE8F7"}]},
    {"featureType": "road", "elementType": "labels.text.stroke", "stylers": [{"visibility": "off"}]},
    {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#E6E0F2"}]},
    {"featureType": "administrative", "elementType": "labels.text.fill", "stylers": [{"color": "#CFC9DE"}]},
    {"featureType": "transit", "stylers": [{"visibility": "off"}]},
    {"featureType": "poi.business", "stylers": [{"visibility": "off"}]}
  ]
  ''';

  static String? forPlatform() {
    // 如需未來針對 Web / Mobile 差異化，可在此切換
    return mijiCustom;
  }
}


