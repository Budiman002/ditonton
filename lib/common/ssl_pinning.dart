import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SSLPinning {
  static const _certificateAsset = 'certificates/certificate.pem';

  /// http.Client yang hanya mempercayai sertifikat pada [_certificateAsset].
  static Future<http.Client> get client async {
    final securityContext = await _globalContext;
    final httpClient = HttpClient(context: securityContext);
    httpClient.badCertificateCallback = (cert, host, port) => false;
    return IOClient(httpClient);
  }

  static Future<SecurityContext> get _globalContext async {
    final sslCert = await rootBundle.load(_certificateAsset);
    final securityContext = SecurityContext(withTrustedRoots: false);
    securityContext.setTrustedCertificatesBytes(sslCert.buffer.asInt8List());
    return securityContext;
  }
}
