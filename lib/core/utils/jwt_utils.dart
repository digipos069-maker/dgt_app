import 'dart:convert';

abstract final class JwtUtils {
  static bool isExpired(
    String token, {
    DateTime? now,
    Duration clockSkew = const Duration(seconds: 30),
  }) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) return true;

      final expiration = _readInt(payload['exp']);
      if (expiration == null) return true;

      final currentSeconds =
          (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
      return expiration <= currentSeconds + clockSkew.inSeconds;
    } on Object {
      return true;
    }
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
