import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';

/// Exposes the shared Dio instance to the rest of the app through Riverpod.
///
/// Any repository can read `ref.watch(dioProvider)` to make API calls, and
/// because it's a single provider, the whole app reuses one configured client.
final dioProvider = Provider<Dio>((ref) => DioClient.create());
