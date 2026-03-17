import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
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
        model: 'gemini-3.1-flash-lite',
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

    final prompt = await _buildPrompt();
    final content = [
      Content.text(prompt),
      Content.text('Here is the text to parse:\n\n---\n$rawText\n---'),
    ];

    final response = await _model!.generateContent(content);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      return null;
    }

    return _parseResponse(responseText);
  }

  /// Parse cruise trip details from booking confirmation file (PDF or Image)
  Future<CruiseTrip?> parseTripFromFile(File file) async {
    if (_model == null) {
      throw Exception('CruiseImportService not initialized with API key');
    }

    final bytes = await file.readAsBytes();
    final extension = file.path.split('.').last.toLowerCase();

    String mimeType;
    if (extension == 'pdf') {
      mimeType = 'application/pdf';
    } else if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'jpg' || extension == 'jpeg') {
      mimeType = 'image/jpeg';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    } else if (extension == 'heic') {
      mimeType = 'image/heic';
    } else {
      throw Exception('Unsupported file format: $extension');
    }

    final prompt = await _buildPrompt();
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, bytes),
      ])
    ];

    final response = await _model!.generateContent(content);
    final responseText = response.text;

    if (responseText == null || responseText.isEmpty) {
      return null;
    }

    return _parseResponse(responseText);
  }

  /// Build the system prompt for the AI
  Future<String> _buildPrompt() async {
    final String portsJsonStr;
    try {
      portsJsonStr = await rootBundle.loadString('assets/ports.json');
    } catch (_) {
      throw Exception('Could not load ports data');
    }

    return '''
You are a highly precise data extraction assistant. Your task is to extract cruise itinerary data from the provided booking screenshot, pdf, or text and map it to a strict JSON format.

I will also provide a JSON list of valid cruise ports (containing 'name' and 'countryCode') below.

Please strictly follow these rules:
1. Extract Overall Data: Identify the start port, end port, overall start date, overall end date, and the ship name (often found at the top near "Reisende" or "mit [Ship Name]").
2. Identify Sea Days: Carefully check the dates in the itinerary table. If a date is skipped between two ports (e.g., Port A on 01.03. and Port B on 03.03.), you MUST insert a stop for the missing date (02.03.) and label it as a Sea Day.
3. Match Country Codes: Use my provided port JSON list to find the correct English "countryCode" for each extracted port "name". If it is a Sea Day, set "countryCode" to null.
4. Coordinates: Set "latitude" and "longitude" explicitly to null for all stops (my app will handle this later).
5. Time Formatting: Format all timestamps exactly as "DD. MMMM YYYY um HH:mm:ss UTC+1" (or UTC+2).
   - If a specific time is given in the image, use it.
   - If the image shows "-" for arrival, use 00:00:00.
   - If the image shows "-" for departure, use 23:59:00.
   - For Sea Days, use 00:00:00 for arrival and 23:59:00 for departure.
6. IDs: Generate a unique, random timestamp-like string ID for each stop.

OUTPUT CONSTRAINT: Output ONLY the raw, valid JSON. Do not include any explanations, markdown formatting blocks, or conversational text. Use exactly this schema:

{
  "arrivalDate": "[End date of the cruise, e.g., 08.03.2025]",
  "departureDate": "[Start date of the cruise, e.g., 01.03.2025]",
  "endPort": "[Name of the final port]",
  "imageUrl": "",
  "shipName": "[Name of the ship, e.g., AIDAnova]",
  "startPort": "[Name of the starting port]",
  "stops": [
    {
      "arrivalTime": "[Arrival time, e.g., '01. March 2025 um 00:00:00 UTC+1']",
      "countryCode": "[Matched English country name, or null for Sea Day]",
      "departureTime": "[Departure time, e.g., '01. March 2025 um 17:00:00 UTC+1']",
      "id": "[Unique string ID]",
      "isSeaDay": true or false,
      "latitude": null,
      "longitude": null,
      "name": "[Port name or 'Sea Day']"
    }
  ]
}

Valid ports list:
$portsJsonStr
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
        final stopMap = stopJson as Map<String, dynamic>;

        // Clean up the custom time string format ("DD. MMMM YYYY um HH:mm:ss UTC+1")
        // to something DateTime.parse() can handle or convert to ISO 8601
        String? cleanTime(String? timeStr) {
          if (timeStr == null || timeStr.isEmpty) return null;

          try {
            DateTime.parse(timeStr);
            return timeStr; // Already valid ISO 8601
          } catch (_) {}

          try {
            // Check for format: 08.03.2025
            final dotParts = timeStr.split('.');
            if (dotParts.length == 3 && dotParts[2].length == 4) {
              return '${dotParts[2]}-${dotParts[1].padLeft(2, '0')}-${dotParts[0].padLeft(2, '0')}T00:00:00';
            }

            // Attempt to parse "01. March 2025 um 17:00:00 UTC+1"
            final parts = timeStr.split(' ');
            if (parts.length >= 4) {
              final dayStr = parts[0].replaceAll('.', '');
              final day = int.parse(dayStr).toString().padLeft(2, '0');

              final monthStr = parts[1];
              int month = 1;
              const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December',
                              'Januar', 'Februar', 'März', 'Mai', 'Juni', 'Juli', 'Oktober', 'Dezember'];
              for (int i = 0; i < months.length; i++) {
                if (months[i].toLowerCase() == monthStr.toLowerCase()) {
                  month = (i % 12) + 1;
                  break;
                }
              }
              final monthFormat = month.toString().padLeft(2, '0');

              final year = parts[2];

              // Find time part
              String time = '00:00:00';
              for (final p in parts) {
                if (p.contains(':')) {
                  time = p;
                  break;
                }
              }

              final t = time.contains(':') ? time : '00:00:00';
              return '$year-$monthFormat-${day}T$t';
            }
          } catch (_) {}

          return null; // Let the model fall back
        }

        if (stopMap.containsKey('arrivalTime')) {
          stopMap['arrivalTime'] = cleanTime(stopMap['arrivalTime']?.toString());
        }
        if (stopMap.containsKey('departureTime')) {
          stopMap['departureTime'] = cleanTime(stopMap['departureTime']?.toString());
        }

        return PortStop.fromMap(stopMap);
      }).toList();

      // Parse dates (handling the DD.MM.YYYY format requested in the new prompt)
      DateTime? parseMainDate(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return null;
        try {
          return DateTime.parse(dateStr); // Try ISO first
        } catch (_) {
          try {
            // Try DD.MM.YYYY
            final parts = dateStr.split('.');
            if (parts.length >= 3) {
              return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          } catch (_) {}
          return null;
        }
      }

      final departureDate = parseMainDate(json['departureDate'] as String?) ?? DateTime.now();
      final arrivalDate = parseMainDate(json['arrivalDate'] as String?) ?? DateTime.now().add(const Duration(days: 7));

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
      throw Exception('Failed to parse AI response. Error: $e\nRaw Response: $responseText');
    }
  }
}

import 'api_keys.dart';

/// Provider for CruiseImportService (singleton)
final cruiseImportServiceProvider = Provider<CruiseImportService?>((ref) {
  // Try environment first, fallback to ApiKeys.gemini
  const envKey = String.fromEnvironment('GEMINI_API_KEY');
  final apiKey = envKey.isNotEmpty ? envKey : ApiKeys.gemini;

  if (apiKey.isEmpty) return null;
  return CruiseImportService(apiKey: apiKey);
});
