import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class PayOSRepository {
  final Dio _dio = Dio();
  
  // URL Server Render của bạn
  static const String _baseUrl = 'https://payos-backend-egnf.onrender.com';

  Future<bool> createPayment({
    required int orderCode,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/create-payment-link',
        data: {
          'orderCode': orderCode,
          'amount': amount.toInt(),
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        final String? checkoutUrl = response.data['checkoutUrl'];
        if (checkoutUrl != null) {
          final Uri url = Uri.parse(checkoutUrl);
          if (await canLaunchUrl(url)) {
            return await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('Không thể mở URL: $checkoutUrl');
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Lỗi PayOSRepository: $e');
      return false;
    }
  }
}
