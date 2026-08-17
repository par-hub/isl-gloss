import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final avatarModelBase64Provider = FutureProvider<String>((ref) async {
  final ByteData data = await rootBundle.load('assets/Avatar2.glb');
  final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  return base64Encode(bytes);
});
