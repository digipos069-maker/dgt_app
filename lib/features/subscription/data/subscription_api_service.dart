import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/app_exception.dart';

class SubscriptionApiService {
  SubscriptionApiService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// 1. POST /api/payment/upload-payslip (FormData: file)
  /// Returns uploaded url (e.g., "/uploads/payslip-1741521234567-891234567.jpg")
  Future<String> uploadPayslip({
    required List<int> fileBytes,
    required String filename,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.uploadPayslipPath}',
    );

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      ),
    );

    final streamed = await _client.send(request).timeout(
          const Duration(seconds: 30),
        );
    final response = await http.Response.fromStream(streamed);
    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        _readMessage(jsonBody) ?? 'Failed to upload payslip',
        statusCode: response.statusCode,
      );
    }

    if (jsonBody is Map<String, dynamic> && jsonBody['url'] != null) {
      return jsonBody['url'].toString();
    }

    throw const AppException('Upload response missing url');
  }

  /// 2. POST /api/payment/bank-transfer
  /// Body: { planId, amount, currency, billingCycle, payslipUrl }
  /// Returns: { message, trxId }
  Future<Map<String, dynamic>> submitBankTransfer({
    required int planId,
    required num amount,
    required String currency,
    required String billingCycle,
    required String payslipUrl,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.bankTransferPaymentPath}',
    );

    final response = await _client
        .post(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'planId': planId,
            'amount': amount,
            'currency': currency.toLowerCase(),
            'billingCycle': billingCycle.toLowerCase(),
            'payslipUrl': payslipUrl,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        _readMessage(jsonBody) ?? 'Failed to submit bank transfer',
        statusCode: response.statusCode,
      );
    }

    if (jsonBody is Map<String, dynamic>) {
      return jsonBody;
    }

    return const <String, dynamic>{};
  }

  /// 3. POST /api/upgrade-subscription
  /// Body: { newPlanId }
  /// Returns: newly created subscription record
  Future<Map<String, dynamic>> upgradeSubscription({
    required int newPlanId,
    required String token,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.upgradeSubscriptionPath}',
    );

    final response = await _client
        .post(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'newPlanId': newPlanId}),
        )
        .timeout(const Duration(seconds: 20));

    final jsonBody = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(
        _readMessage(jsonBody) ?? 'Failed to upgrade subscription',
        statusCode: response.statusCode,
      );
    }

    if (jsonBody is Map<String, dynamic>) {
      return jsonBody;
    }

    return const <String, dynamic>{};
  }

  Object? _decodeBody(String body) {
    if (body.trim().isEmpty) return const <String, dynamic>{};
    try {
      return jsonDecode(body);
    } on FormatException {
      return <String, dynamic>{'message': body.trim()};
    }
  }

  String? _readMessage(Object? jsonBody) {
    if (jsonBody is! Map<String, dynamic>) return null;
    final message = jsonBody['message'];
    if (message is List && message.isNotEmpty) {
      return message.map((e) => e.toString()).join(', ');
    }
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    final error = jsonBody['error'];
    return error is String && error.trim().isNotEmpty ? error.trim() : null;
  }
}
