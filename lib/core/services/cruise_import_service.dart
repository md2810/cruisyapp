import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../shared/models/cruise_trip.dart';
import '../../shared/models/port_stop.dart';

/// Service for parsing cruise booking confirmations using AI
class CruiseImportService {
  final String? apiKey;
  GenerativeModel? _model;

  CruiseImportService({this.apiKey}) {
    if (apiKey != null && apiKey!.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey!,
      );
    }
  }

  /// Whether the service is available (has valid API key)
  bool get isAvailable => _model != null;

  /// Parse cruise trip details from booking confirmation text
  Future<CruiseTrip?> parseTripFromText(String rawText) async {
    if (_model == null) {
      throw Exception('CruiseImportService not initialized with API key');
    }

    if (rawText.trim().isEmpty) {
      return null;
    }

    final prompt = _buildPrompt(rawText);
    final content = [Content.text(prompt)];

    final response = await _model!.generateContent(content);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      return null;
    }

    return _parseResponse(responseText);
  }

  /// Build the system prompt for the AI
  String _buildPrompt(String rawText) {
    return '''
You are a cruise booking parser. Extract structured cruise information from the provided booking confirmation text.

Extract the following information and return it as a STRICT JSON object:

{
  "shipName": "string (required) - Name of the cruise ship",
  "tripName": "string (optional) - Name/title of the trip, if not found use empty string",
  "departureDate": "ISO 8601 date string (required) - Cruise departure date",
  "arrivalDate": "ISO 8601 date string (required) - Cruise arrival/end date",
  "startPort": "string (required) - Name of departure port",
  "endPort": "string (required) - Name of arrival/disembarkation port",
  "stops": [
    {
      "id": "string - unique identifier (use port name + timestamp)",
      "name": "string - Port name",
      "arrivalTime": "ISO 8601 datetime string or null",
      "departureTime": "ISO 8601 datetime string or null",
      "isSeaDay": false,
      "countryCode": "2-letter country code if available, else null",
      "latitude": number or null,
      "longitude": number or null
    }
  ]
}

IMPORTANT RULES:
1. Return ONLY the JSON object, no markdown formatting, no backticks, no explanations
2. All dates MUST be in ISO 8601 format (YYYY-MM-DDTHH:mm:ss)
3. For dates without time, use midnight (00:00:00) for arrival and 23:59:59 for departure
4. First port: arrivalTime can be null (will default to cruise start)
5. Last port: departureTime can be null (will default to cruise end)
6. Sea days should NOT be included as separate stops - only actual ports
7. Use realistic coordinates for known ports if you can infer them
8. If the text is not a cruise booking, return {"error": "Not a cruise booking"}

Here is the booking confirmation text to parse:

---
$rawText
---

Extract the cruise details and return as JSON:
''';
  }

  /// Parse the AI response into a CruiseTrip object
  CruiseTrip? _parseResponse(String responseText) {
    try {
      // Clean up the response - remove markdown code blocks if present
      String cleaned = responseText.trim();
      
      // Remove markdown code block markers
      if (cleaned.startsWith('```json')) {
        cleaned = cleaned.substring(7);
      } else if (cleaned.startsWith('```')) {
        cleaned = cleaned.substring(3);
      }
      
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3);
      }
      
      cleaned = cleaned.trim();

      final json = jsonDecode(cleaned) as Map<String, dynamic>;

      // Check for error
      if (json['error'] != null) {
        return null;
      }

      // Parse stops
      final stopsJson = json['stops'] as List<dynamic>? ?? [];
      final stops = stopsJson.map((stopJson) {
        return PortStop.fromMap(stopJson as Map<String, dynamic>);
      }).toList();

      // Parse dates
      final departureDate = _parseDate(json['departureDate'] as String?) ?? DateTime.now();
      final arrivalDate = _parseDate(json['arrivalDate'] as String?) ?? DateTime.now().add(const Duration(days: 7));

      // Create CruiseTrip
      return CruiseTrip(
        id: '', // Will be assigned by Firestore
        shipName: json['shipName'] as String? ?? 'Unknown Ship',
        tripName: json['tripName'] as String? ?? 'Cruise Adventure',
        departureDate: departureDate,
        arrivalDate: arrivalDate,
        startPort: json['startPort'] as String? ?? (stops.isNotEmpty ? stops.first.name : 'Unknown'),
        endPort: json['endPort'] as String? ?? (stops.isNotEmpty ? stops.last.name : 'Unknown'),
        stops: stops,
        imageUrl: 'https://images.unsplash.com/photo-1548574505-5e239809ee19?q=80&w=1000&auto=format&fit=crop',
      );
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }

  /// Parse ISO 8601 date string
  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }
}

/// Provider for CruiseImportService (singleton)
final cruiseImportServiceProvider = Provider<CruiseImportService?>((ref) {
  // API key should be configured via environment or secure storage
  // For now, return null if not configured
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isEmpty) return null;
  return CruiseImportService(apiKey: apiKey);
});
