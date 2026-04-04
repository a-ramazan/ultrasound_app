import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/analysis_result.dart';
import '../models/roi_box.dart';

class AnalysisApiService {
  const AnalysisApiService();

  Future<AnalysisResult> analyze({
    required Uint8List imageBytes,
    required RoiBox roi,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/analyze');
    final request = http.MultipartRequest('POST', uri)
      ..fields['roi_x'] = roi.x.toString()
      ..fields['roi_y'] = roi.y.toString()
      ..fields['roi_width'] = roi.width.toString()
      ..fields['roi_height'] = roi.height.toString()
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'ultrasound.png',
        ),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AnalysisResult.fromApi(
      originalImageBytes: imageBytes,
      predictedClass: (json['predicted_class'] as String?) ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      overlayImageBase64: (json['overlay_image_base64'] as String?) ?? '',
      segmentationMaskBase64:
          (json['segmentation_mask_base64'] as String?) ?? '',
    );
  }
}
