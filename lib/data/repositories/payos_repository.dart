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
      // LOGIC MỚI: Chỉ lấy 4 chữ số đầu tiên từ trái qua để test Sandbox
      // Ví dụ: 2.090.500 -> "2090500" -> "2090" -> 2090đ
      String amountStr = amount.toInt().toString();
      int testAmount = amount.toInt();
      if (amountStr.length > 4) {
        testAmount = int.parse(amountStr.substring(0, 4));
      }

      final response = await _dio.post(
        '$_baseUrl/create-payment-link',
        data: {
          'orderCode': orderCode,
          'amount': testAmount, // Gửi số tiền đã được "thu gọn"
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
  Future<String> verifyPayment(int orderCode) async {
    try {
      final response = await _dio.get('$_baseUrl/verify-payment/$orderCode');
      if (response.statusCode == 200 && response.data['code'] == '00') {
        return response.data['data']['status']; // Trả về 'PAID', 'PENDING', 'CANCELLED'
      }
      return 'ERROR';
    } catch (e) {
      return 'ERROR';
    }
  }
}
