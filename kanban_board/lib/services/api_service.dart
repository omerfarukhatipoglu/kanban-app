// ignore_for_file: unintended_html_in_doc_comment

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => "ApiException($statusCode): $message";
}

class ApiService {
  /// Android Emulator  : http://10.0.2.2:8080
  /// iOS Simulator    : http://localhost:8080
  /// Gerçek Cihaz     : http://<PC-IP>:8080
  static const String _baseUrl = "http://localhost:8080";

  final http.Client _client = http.Client();

  Uri _uri(String path) => Uri.parse("$_baseUrl$path");

  Map<String, String> get _headers => const {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  String _extractErrorMessage(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data["error"] is String) {
        return data["error"] as String;
      }
    } catch (_) {}
    return res.body.isNotEmpty ? res.body : "Unknown error";
  }

  Map<String, dynamic> _decodeMap(http.Response res) {
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException(
      res.statusCode,
      "Invalid response format (expected object)",
    );
  }

  void _throwIfNot2xx(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw ApiException(res.statusCode, _extractErrorMessage(res));
  }

  Future<bool> health() async {
    final res = await _client.get(_uri("/health"), headers: _headers);
    if (res.statusCode != 200) return false;
    final data = _decodeMap(res);
    return data["ok"] == "true";
  }

  Future<Map<String, dynamic>> createBoard({required String title}) async {
    final res = await _client.post(
      _uri("/boards"),
      headers: _headers,
      body: jsonEncode({"title": title}),
    );
    _throwIfNot2xx(res);
    return _decodeMap(res);
  }

  Future<Map<String, dynamic>> getBoard(String boardId) async {
    final res = await _client.get(_uri("/boards/$boardId"), headers: _headers);
    _throwIfNot2xx(res);
    return _decodeMap(res);
  }

  Future<void> updateBoardTitle({
    required String boardId,
    required String title,
  }) async {
    final res = await _client.patch(
      _uri("/boards/$boardId"),
      headers: _headers,
      body: jsonEncode({"title": title}),
    );
    _throwIfNot2xx(res);
  }

  Future<void> deleteBoard(String boardId) async {
    final res = await _client.delete(
      _uri("/boards/$boardId"),
      headers: _headers,
    );
    _throwIfNot2xx(res);
  }

  Future<Map<String, dynamic>> createCard({
    required String boardId,
    required String list,
    required String title,
    String? description,
  }) async {
    final uri = Uri.parse("$_baseUrl/boards/$boardId/cards");

    final body = <String, dynamic>{"list": list, "title": title};

    if (description != null) body["description"] = description;

    final res = await _client.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("createCard failed: ${res.statusCode} ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCard({
    required String boardId,
    required String cardId,
    String? title,
    String? description,
    bool clearDescription = false,
    String? list,
    int? order,
    String? colorHex,
  }) async {
    final uri = Uri.parse("$_baseUrl/boards/$boardId/cards/$cardId");

    final body = <String, dynamic>{};

    if (title != null) body["title"] = title;

    if (clearDescription) {
      body["description"] = "";
    } else if (description != null) {
      body["description"] = description;
    }

    if (list != null) body["list"] = list;
    if (order != null) body["order"] = order;
    if (colorHex != null) body["colorHex"] = colorHex;

    final res = await _client.patch(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("updateCard failed: ${res.statusCode} ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> deleteCard({
    required String boardId,
    required String cardId,
  }) async {
    final uri = Uri.parse("$_baseUrl/boards/$boardId/cards/$cardId");

    final res = await _client.delete(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("deleteCard failed: ${res.statusCode} ${res.body}");
    }
  }

  Future<void> updateBoard({
    required String boardId,
    required String title,
  }) async {
    final uri = Uri.parse("$_baseUrl/boards/$boardId");
    final res = await http.patch(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Board update failed: ${res.body}");
    }
  }

  void dispose() {
    _client.close();
  }
}
