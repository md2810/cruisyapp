import 'dart:convert';
import 'dart:io';

import 'package:cruisyapp/core/providers/ai_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../shared/models/cruise_trip.dart';
import '../../shared/models/port_stop.dart';
import 'port_search_service.dart';

/// Service for parsing cruise booking confirmations using the user's AI provider.
class CruiseImportService {
  CruiseImportService({
    required ActiveAiConfiguration configuration,
    http.Client? client,
  }) : _configuration = configuration,
       _client = client ?? http.Client();

  final ActiveAiConfiguration _configuration;
  final http.Client _client;

  bool get isAvailable =>
      _configuration.apiKey.isNotEmpty && _configuration.model.isNotEmpty;

  Future<CruiseTrip?> parseTripFromText(String rawText) async {
    _assertConfigured();

    if (rawText.trim().isEmpty) {
      return null;
    }

    final prompt = await _buildPrompt();
    final responseText = await _generateFromText(
      prompt: prompt,
      rawText: rawText,
    );

    if (responseText == null || responseText.trim().isEmpty) {
      return null;
    }

    return _parseResponse(responseText);
  }

  Future<CruiseTrip?> parseTripFromFile(File file) async {
    _assertConfigured();

    final filePayload = await _AiFilePayload.fromFile(
      file,
      provider: _configuration.provider,
    );
    final prompt = await _buildPrompt();
    final responseText = await _generateFromFile(
      prompt: prompt,
      filePayload: filePayload,
    );

    if (responseText == null || responseText.trim().isEmpty) {
      return null;
    }

    return _parseResponse(responseText);
  }

  void _assertConfigured() {
    if (!isAvailable) {
      throw Exception('AI import is not configured.');
    }
  }

  Future<String?> _generateFromText({
    required String prompt,
    required String rawText,
  }) {
    return switch (_configuration.provider) {
      AiProviderType.google => _generateWithGoogle(
        parts: <Map<String, dynamic>>[
          {'text': prompt},
          {'text': 'Here is the text to parse:\n\n---\n$rawText\n---'},
        ],
      ),
      AiProviderType.anthropic => _generateWithAnthropic(
        content: <Map<String, dynamic>>[
          {
            'type': 'text',
            'text':
                '$prompt\n\nHere is the text to parse:\n\n---\n$rawText\n---',
          },
        ],
      ),
      AiProviderType.openai => _generateWithOpenAi(
        content: <Map<String, dynamic>>[
          {'type': 'input_text', 'text': prompt},
          {
            'type': 'input_text',
            'text': 'Here is the text to parse:\n\n---\n$rawText\n---',
          },
        ],
      ),
      AiProviderType.mistral => _generateWithMistral(
        content: <Object>[
          {
            'type': 'text',
            'text':
                '$prompt\n\nHere is the text to parse:\n\n---\n$rawText\n---',
          },
        ],
      ),
    };
  }

  Future<String?> _generateFromFile({
    required String prompt,
    required _AiFilePayload filePayload,
  }) async {
    return switch (_configuration.provider) {
      AiProviderType.google => _generateWithGoogle(
        parts: <Map<String, dynamic>>[
          {'text': prompt},
          {
            'inline_data': <String, dynamic>{
              'mime_type': filePayload.mimeType,
              'data': filePayload.base64Data,
            },
          },
        ],
      ),
      AiProviderType.anthropic => _generateWithAnthropic(
        content: <Map<String, dynamic>>[
          filePayload.isPdf
              ? <String, dynamic>{
                'type': 'document',
                'source': <String, dynamic>{
                  'type': 'base64',
                  'media_type': filePayload.mimeType,
                  'data': filePayload.base64Data,
                },
              }
              : <String, dynamic>{
                'type': 'image',
                'source': <String, dynamic>{
                  'type': 'base64',
                  'media_type': filePayload.mimeType,
                  'data': filePayload.base64Data,
                },
              },
          {'type': 'text', 'text': prompt},
        ],
      ),
      AiProviderType.openai => _generateWithOpenAi(
        content: <Map<String, dynamic>>[
          if (filePayload.isPdf)
            {
              'type': 'input_file',
              'file_id': await _uploadOpenAiFile(filePayload),
            }
          else
            {'type': 'input_image', 'image_url': filePayload.dataUrl},
          {'type': 'input_text', 'text': prompt},
        ],
      ),
      AiProviderType.mistral =>
        filePayload.isPdf
            ? _generateWithMistralPdf(prompt: prompt, filePayload: filePayload)
            : _generateWithMistral(
              content: <Object>[
                {'type': 'text', 'text': prompt},
                {'type': 'image_url', 'image_url': filePayload.dataUrl},
              ],
            ),
    };
  }

  Future<String?> _generateWithGoogle({
    required List<Map<String, dynamic>> parts,
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/${_configuration.model}:generateContent?key=${Uri.encodeQueryComponent(_configuration.apiKey)}',
      ),
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'contents': <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'parts': parts},
        ],
        'generationConfig': const <String, dynamic>{'temperature': 0.1},
      }),
    );

    final json = _decodeJsonResponse(
      provider: AiProviderType.google,
      response: response,
    );
    final candidates =
        json['candidates'] as List<dynamic>? ?? const <dynamic>[];
    if (candidates.isEmpty) {
      return null;
    }

    final content =
        (candidates.first as Map<String, dynamic>)['content']
            as Map<String, dynamic>?;
    final partsJson = content?['parts'] as List<dynamic>? ?? const <dynamic>[];
    final buffer = StringBuffer();
    for (final part in partsJson.whereType<Map<String, dynamic>>()) {
      final text = part['text']?.toString();
      if (text != null && text.isNotEmpty) {
        if (buffer.isNotEmpty) {
          buffer.writeln();
        }
        buffer.write(text);
      }
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  Future<String?> _generateWithAnthropic({
    required List<Map<String, dynamic>> content,
  }) async {
    final response = await _client.post(
      Uri.https('api.anthropic.com', '/v1/messages'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'anthropic-version': '2023-06-01',
        'x-api-key': _configuration.apiKey,
      },
      body: jsonEncode(<String, dynamic>{
        'model': _configuration.model,
        'max_tokens': 4096,
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': content},
        ],
      }),
    );

    final json = _decodeJsonResponse(
      provider: AiProviderType.anthropic,
      response: response,
    );
    final blocks = json['content'] as List<dynamic>? ?? const <dynamic>[];
    final buffer = StringBuffer();
    for (final block in blocks.whereType<Map<String, dynamic>>()) {
      if (block['type'] == 'text') {
        final text = block['text']?.toString();
        if (text != null && text.isNotEmpty) {
          if (buffer.isNotEmpty) {
            buffer.writeln();
          }
          buffer.write(text);
        }
      }
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  Future<String?> _generateWithOpenAi({
    required List<Map<String, dynamic>> content,
  }) async {
    final response = await _client.post(
      Uri.https('api.openai.com', '/v1/responses'),
      headers: <String, String>{
        'Authorization': 'Bearer ${_configuration.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'model': _configuration.model,
        'input': <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': content},
        ],
      }),
    );

    final json = _decodeJsonResponse(
      provider: AiProviderType.openai,
      response: response,
    );
    final outputText = json['output_text'];
    if (outputText is String && outputText.isNotEmpty) {
      return outputText;
    }

    final outputs = json['output'] as List<dynamic>? ?? const <dynamic>[];
    final buffer = StringBuffer();

    for (final output in outputs.whereType<Map<String, dynamic>>()) {
      final contentItems =
          output['content'] as List<dynamic>? ?? const <dynamic>[];
      for (final item in contentItems.whereType<Map<String, dynamic>>()) {
        final type = item['type']?.toString();
        if (type == 'output_text' || type == 'text') {
          final textValue = item['text'];
          final text = switch (textValue) {
            String() => textValue,
            Map<String, dynamic>() => textValue['value']?.toString(),
            _ => null,
          };
          if (text != null && text.isNotEmpty) {
            if (buffer.isNotEmpty) {
              buffer.writeln();
            }
            buffer.write(text);
          }
        }
      }
    }

    return buffer.isEmpty ? null : buffer.toString();
  }

  Future<String?> _generateWithMistral({required List<Object> content}) async {
    final response = await _client.post(
      Uri.https('api.mistral.ai', '/v1/chat/completions'),
      headers: <String, String>{
        'Authorization': 'Bearer ${_configuration.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'model': _configuration.model,
        'messages': <Map<String, dynamic>>[
          <String, dynamic>{'role': 'user', 'content': content},
        ],
        'temperature': 0.1,
      }),
    );

    final json = _decodeJsonResponse(
      provider: AiProviderType.mistral,
      response: response,
    );
    final choices = json['choices'] as List<dynamic>? ?? const <dynamic>[];
    if (choices.isEmpty) {
      return null;
    }

    final message =
        (choices.first as Map<String, dynamic>)['message']
            as Map<String, dynamic>?;
    final contentValue = message?['content'];
    if (contentValue is String && contentValue.isNotEmpty) {
      return contentValue;
    }

    if (contentValue is List<dynamic>) {
      final buffer = StringBuffer();
      for (final item in contentValue.whereType<Map<String, dynamic>>()) {
        final text = item['text']?.toString();
        if (text != null && text.isNotEmpty) {
          if (buffer.isNotEmpty) {
            buffer.writeln();
          }
          buffer.write(text);
        }
      }
      return buffer.isEmpty ? null : buffer.toString();
    }

    return null;
  }

  Future<String?> _generateWithMistralPdf({
    required String prompt,
    required _AiFilePayload filePayload,
  }) async {
    final fileId = await _uploadMistralOcrFile(filePayload);
    final response = await _client.post(
      Uri.https('api.mistral.ai', '/v1/ocr'),
      headers: <String, String>{
        'Authorization': 'Bearer ${_configuration.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'document': <String, dynamic>{'file_id': fileId},
      }),
    );

    final json = _decodeJsonResponse(
      provider: AiProviderType.mistral,
      response: response,
    );
    final pages = json['pages'] as List<dynamic>? ?? const <dynamic>[];
    final extractedText = pages
        .whereType<Map<String, dynamic>>()
        .map(
          (page) =>
              page['markdown']?.toString() ?? page['text']?.toString() ?? '',
        )
        .where((pageText) => pageText.isNotEmpty)
        .join('\n\n');

    if (extractedText.isEmpty) {
      return null;
    }

    return _generateWithMistral(
      content: <Object>[
        {
          'type': 'text',
          'text':
              '$prompt\n\nHere is the OCR text to parse:\n\n---\n$extractedText\n---',
        },
      ],
    );
  }

  Future<String> _uploadOpenAiFile(_AiFilePayload filePayload) async {
    final request =
        http.MultipartRequest('POST', Uri.https('api.openai.com', '/v1/files'))
          ..headers['Authorization'] = 'Bearer ${_configuration.apiKey}'
          ..fields['purpose'] = 'user_data'
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              filePayload.bytes,
              filename: filePayload.filename,
            ),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final json = _decodeJsonResponse(
      provider: AiProviderType.openai,
      response: response,
    );

    final fileId = json['id']?.toString();
    if (fileId == null || fileId.isEmpty) {
      throw Exception('OpenAI file upload did not return a file id.');
    }
    return fileId;
  }

  Future<String> _uploadMistralOcrFile(_AiFilePayload filePayload) async {
    final request =
        http.MultipartRequest('POST', Uri.https('api.mistral.ai', '/v1/files'))
          ..headers['Authorization'] = 'Bearer ${_configuration.apiKey}'
          ..fields['purpose'] = 'ocr'
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              filePayload.bytes,
              filename: filePayload.filename,
            ),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final json = _decodeJsonResponse(
      provider: AiProviderType.mistral,
      response: response,
    );

    final fileId = json['id']?.toString();
    if (fileId == null || fileId.isEmpty) {
      throw Exception('Mistral OCR upload did not return a file id.');
    }
    return fileId;
  }

  Map<String, dynamic> _decodeJsonResponse({
    required AiProviderType provider,
    required http.Response response,
  }) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      decoded = jsonDecode(response.body);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractProviderErrorMessage(decoded);
      throw Exception(
        '${provider.displayName} request failed (${response.statusCode})${message == null ? '' : ': $message'}',
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('${provider.displayName} returned an unexpected response.');
  }

  String? _extractProviderErrorMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        return error['message']?.toString() ??
            error['detail']?.toString() ??
            error['type']?.toString();
      }
      return decoded['message']?.toString() ?? decoded['detail']?.toString();
    }
    if (decoded is String && decoded.isNotEmpty) {
      return decoded;
    }
    return null;
  }

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
   - If a specific time is given in the document, use it.
   - If the document shows "-" for arrival, use 00:00:00.
   - If the document shows "-" for departure, use 23:59:00.
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

  CruiseTrip? _parseResponse(String responseText) {
    try {
      var cleaned = responseText.trim();

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

      if (json['error'] != null) {
        return null;
      }

      final portSearchService = PortSearchService();
      final stopsJson = json['stops'] as List<dynamic>? ?? const <dynamic>[];
      final stops =
          stopsJson.whereType<Map<String, dynamic>>().map((stopMap) {
            final normalizedStopMap = Map<String, dynamic>.from(stopMap);

            if (normalizedStopMap.containsKey('arrivalTime')) {
              normalizedStopMap['arrivalTime'] = _normalizeAiDateTime(
                normalizedStopMap['arrivalTime']?.toString(),
              );
            }
            if (normalizedStopMap.containsKey('departureTime')) {
              normalizedStopMap['departureTime'] = _normalizeAiDateTime(
                normalizedStopMap['departureTime']?.toString(),
              );
            }

            final isSeaDay = normalizedStopMap['isSeaDay'] == true;
            if (!isSeaDay) {
              final portName = normalizedStopMap['name'] as String?;
              final countryCode = normalizedStopMap['countryCode'] as String?;
              if (portName != null && portName.isNotEmpty) {
                final portInfo = portSearchService.findByName(
                  portName,
                  countryCode: countryCode,
                );
                if (portInfo != null) {
                  normalizedStopMap['latitude'] = portInfo.latitude;
                  normalizedStopMap['longitude'] = portInfo.longitude;
                }
              }
            }

            return PortStop.fromMap(normalizedStopMap);
          }).toList();

      final departureDate =
          _parseMainDate(json['departureDate'] as String?) ?? DateTime.now();
      final arrivalDate =
          _parseMainDate(json['arrivalDate'] as String?) ??
          DateTime.now().add(const Duration(days: 7));

      return CruiseTrip(
        id: '',
        shipName: json['shipName'] as String? ?? 'Unknown Ship',
        tripName: json['tripName'] as String? ?? 'Cruise Adventure',
        departureDate: departureDate,
        arrivalDate: arrivalDate,
        startPort:
            json['startPort'] as String? ??
            (stops.isNotEmpty ? stops.first.name : 'Unknown'),
        endPort:
            json['endPort'] as String? ??
            (stops.isNotEmpty ? stops.last.name : 'Unknown'),
        stops: stops,
        imageUrl:
            'https://images.unsplash.com/photo-1548574505-5e239809ee19?q=80&w=1000&auto=format&fit=crop',
      );
    } catch (error) {
      throw Exception(
        'Failed to parse AI response. Error: $error\nRaw Response: $responseText',
      );
    }
  }

  String? _normalizeAiDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final trimmedValue = value.trim();
    try {
      DateTime.parse(trimmedValue);
      return trimmedValue;
    } catch (_) {
      // Try custom formats below.
    }

    final dotDateMatch = RegExp(
      r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$',
    ).firstMatch(trimmedValue);
    if (dotDateMatch != null) {
      final day = dotDateMatch.group(1)!.padLeft(2, '0');
      final month = dotDateMatch.group(2)!.padLeft(2, '0');
      final year = dotDateMatch.group(3)!;
      return '$year-$month-${day}T00:00:00';
    }

    final longDateMatch = RegExp(
      r'^(\d{1,2})\.\s*([A-Za-zÄÖÜäöüß]+)\s+(\d{4})(?:\s+um\s+(\d{2}:\d{2}:\d{2}))?(?:\s+UTC[+-]\d+)?$',
      caseSensitive: false,
    ).firstMatch(trimmedValue);

    if (longDateMatch != null) {
      final day = longDateMatch.group(1)!.padLeft(2, '0');
      final monthName = longDateMatch.group(2)!.toLowerCase();
      final year = longDateMatch.group(3)!;
      final time = longDateMatch.group(4) ?? '00:00:00';

      const monthLookup = <String, String>{
        'january': '01',
        'januar': '01',
        'february': '02',
        'februar': '02',
        'march': '03',
        'märz': '03',
        'maerz': '03',
        'april': '04',
        'may': '05',
        'mai': '05',
        'june': '06',
        'juni': '06',
        'july': '07',
        'juli': '07',
        'august': '08',
        'september': '09',
        'october': '10',
        'oktober': '10',
        'november': '11',
        'december': '12',
        'dezember': '12',
      };

      final month = monthLookup[monthName];
      if (month != null) {
        return '$year-$month-${day}T$time';
      }
    }

    return null;
  }

  DateTime? _parseMainDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      final match = RegExp(
        r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$',
      ).firstMatch(value.trim());
      if (match == null) {
        return null;
      }

      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(2)!),
        int.parse(match.group(1)!),
      );
    }
  }
}

final cruiseImportServiceProvider = Provider<CruiseImportService?>((ref) {
  final configuration = ref.watch(activeAiConfigurationProvider);
  if (configuration == null) {
    return null;
  }

  return CruiseImportService(configuration: configuration);
});

class _AiFilePayload {
  const _AiFilePayload({
    required this.filename,
    required this.mimeType,
    required this.bytes,
  });

  final String filename;
  final String mimeType;
  final List<int> bytes;

  bool get isPdf => mimeType == 'application/pdf';

  bool get isImage => mimeType.startsWith('image/');

  String get base64Data => base64Encode(bytes);

  String get dataUrl => 'data:$mimeType;base64,$base64Data';

  static Future<_AiFilePayload> fromFile(
    File file, {
    required AiProviderType provider,
  }) async {
    final filename =
        file.uri.pathSegments.isNotEmpty
            ? file.uri.pathSegments.last
            : file.path;
    final extension =
        filename.contains('.') ? filename.split('.').last.toLowerCase() : '';
    final mimeType = _mimeTypeForExtension(
      extension: extension,
      provider: provider,
    );
    final bytes = await file.readAsBytes();

    return _AiFilePayload(filename: filename, mimeType: mimeType, bytes: bytes);
  }

  static String _mimeTypeForExtension({
    required String extension,
    required AiProviderType provider,
  }) {
    if (extension == 'pdf') {
      return 'application/pdf';
    }

    final commonImageTypes = <String, String>{
      'gif': 'image/gif',
      'jpeg': 'image/jpeg',
      'jpg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
    };

    final googleImageTypes = <String, String>{
      ...commonImageTypes,
      'heic': 'image/heic',
    };

    final imageTypes =
        provider == AiProviderType.google ? googleImageTypes : commonImageTypes;
    final mimeType = imageTypes[extension];
    if (mimeType != null) {
      return mimeType;
    }

    throw Exception(
      'Unsupported file format .$extension for ${provider.displayName}. Use PDF, PNG, JPG, GIF, or WEBP${provider == AiProviderType.google ? ', or HEIC' : ''}.',
    );
  }
}
