class MapStyles {
  // 未來主義玻璃態地圖樣式
  static const String futuristicGlassmorphism = '''
  [
    {"featureType": "all", "elementType": "geometry", "stylers": [{"color": "#0a0a0a"}]},
    {"featureType": "all", "elementType": "labels", "stylers": [{"visibility": "off"}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#0f0f0f"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#001122"}]},
    {"featureType": "water", "elementType": "geometry.fill", "stylers": [{"color": "#002244"}]},
    {"featureType": "water", "elementType": "geometry.stroke", "stylers": [{"color": "#00aaff"}, {"weight": 2}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#1a1a1a"}]},
    {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#dda0dd"}, {"weight": 1}]},
    {"featureType": "road", "elementType": "labels", "stylers": [{"visibility": "off"}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#2a2a2a"}]},
    {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#ff69b4"}, {"weight": 2}]},
    {"featureType": "road.highway", "elementType": "labels", "stylers": [{"visibility": "off"}]},
    {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#222222"}]},
    {"featureType": "road.arterial", "elementType": "geometry.stroke", "stylers": [{"color": "#da70d6"}, {"weight": 1}]},
    {"featureType": "road.local", "elementType": "geometry", "stylers": [{"color": "#1f1f1f"}]},
    {"featureType": "road.local", "elementType": "geometry.stroke", "stylers": [{"color": "#ee82ee"}, {"weight": 1}]},
    {"featureType": "poi", "stylers": [{"visibility": "off"}]},
    {"featureType": "transit", "stylers": [{"visibility": "off"}]},
    {"featureType": "administrative", "stylers": [{"visibility": "off"}]},
    {"featureType": "administrative.country", "stylers": [{"visibility": "off"}]},
    {"featureType": "administrative.province", "stylers": [{"visibility": "off"}]},
    {"featureType": "administrative.locality", "stylers": [{"visibility": "off"}]},
    {"featureType": "landscape.man_made", "elementType": "geometry", "stylers": [{"color": "#1a1a1a"}, {"visibility": "simplified"}]},
    {"featureType": "landscape.natural", "elementType": "geometry", "stylers": [{"color": "#0f0f0f"}]},
    {"featureType": "administrative.neighborhood", "elementType": "geometry.stroke", "stylers": [{"color": "#aa00ff"}, {"weight": 1}]}
  ]
  ''';

  // 原始簡潔樣式
  static const String mijiCustom = '''
  [
    {"featureType": "all", "elementType": "geometry", "stylers": [{"color": "#212121"}]},
    {"featureType": "all", "elementType": "labels", "stylers": [{"visibility": "off"}]},
    {"featureType": "poi", "stylers": [{"visibility": "off"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#404040"}]},
    {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#606060"}, {"weight": 1}]},
    {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#505050"}]},
    {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#707070"}, {"weight": 2}]},
    {"featureType": "transit", "stylers": [{"visibility": "off"}]},
    {"featureType": "administrative", "stylers": [{"visibility": "off"}]},
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#2E4A6B"}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#2F2C44"}]}
  ]
  ''';

  // 玻璃感霓虹風格地圖樣式 - 深藍漸層背景，半透明毛玻璃層，霓虹藍街道，發光河流
  static const String futuristicNeonGlass = '''
  [
    {
      "featureType": "all",
      "elementType": "geometry",
      "stylers": [
        {"color": "#0A0A1A"}
      ]
    },
    {
      "featureType": "all",
      "elementType": "labels",
      "stylers": [
        {"visibility": "off"}
      ]
    },
    {
      "featureType": "poi",
      "stylers": [
        {"visibility": "off"}
      ]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [
        {"color": "#0F0F2A"}
      ]
    },
    {
      "featureType": "landscape.natural",
      "elementType": "geometry",
      "stylers": [
        {"color": "#0A0A1A"}
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {"color": "#1A1A2A"}
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [
        {"color": "#00BFFF"},
        {"weight": 1}
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.stroke",
      "stylers": [
        {"color": "#00FFFF"},
        {"weight": 2}
      ]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry.stroke",
      "stylers": [
        {"color": "#0099FF"},
        {"weight": 2}
      ]
    },
    {
      "featureType": "road.local",
      "elementType": "geometry.stroke",
      "stylers": [
        {"color": "#0066CC"},
        {"weight": 1}
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {"color": "#001133"}
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry.stroke",
      "stylers": [
        {"color": "#33DDFF"},
        {"weight": 3}
      ]
    },
    {
      "featureType": "water",
      "elementType": "labels",
      "stylers": [
        {"visibility": "off"}
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry.stroke",
      "stylers": [
        {"color": "#004499"},
        {"weight": 1}
      ]
    },
    {
      "featureType": "transit",
      "stylers": [
        {"visibility": "off"}
      ]
    }
  ]
  ''';

  static String? forPlatform() {
    return futuristicNeonGlass;
  }
}
