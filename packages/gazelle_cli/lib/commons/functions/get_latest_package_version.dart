import 'dart:convert';

import 'package:http/http.dart' as http;

const _pubApiPackagesBasePath = "https://pub.dev/api/packages";

/// Returns the latest version number for the given [packageName].
Future<String> getLatestPackageVersion(String packageName) async {
  final uri = Uri.parse("$_pubApiPackagesBasePath/$packageName");
  final response = await http.get(uri).then((res) => jsonDecode(res.body));

  return response['latest']['version'].toString();
}
