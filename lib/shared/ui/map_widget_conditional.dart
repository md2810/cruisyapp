// Conditional import for MapWidget - uses stub on web, real implementation on mobile
export 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'
    if (dart.library.html) 'map_widget_stub.dart';
