// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Exception thrown when generating content fails.
///
/// The [message] may explain the cause of the failure.
/// The [code] contains the error code when available.
final class GenerativeAIException implements Exception {
  final String message;
  final int? code;

  GenerativeAIException(this.message, {this.code});

  @override
  String toString() => 'GenerativeAIException: $message';
}

/// Exception thrown when the server rejects the API key.
final class InvalidApiKey implements GenerativeAIException {
  @override
  final String message;
  @override
  final int? code;

  InvalidApiKey(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown when the user location is unsupported.
final class UnsupportedUserLocation implements GenerativeAIException {
  static const _message = 'User location is not supported for the API use.';
  @override
  String get message => _message;
  @override
  final int? code;

  UnsupportedUserLocation({this.code});
}

/// Exception thrown when the quota is exceeded.
final class QuotaExceeded implements GenerativeAIException {
  // ignore: public_member_api_docs
  QuotaExceeded(this.message, this.details, {this.code});
  @override
  final String message;
  @override
  final int? code;

  final dynamic details;

  @override
  String toString() => message;
}

/// Exception thrown when the server failed to generate content.
final class ServerException implements GenerativeAIException {
  @override
  final String message;
  @override
  final int? code;

  ServerException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception indicating a stale package version or implementation bug.
///
/// This exception indicates a likely problem with the SDK implementation such
/// as an inability to parse a new response format. Resolution paths may include
/// updating to a new version of the SDK, or filing an issue.
final class GenerativeAISdkException implements Exception {
  final String message;

  GenerativeAISdkException(this.message);

  @override
  String toString() =>
      '$message\n'
      'This indicates a problem with the Google Generative AI SDK. '
      'Try updating to the latest version '
      '(https://pub.dev/packages/google_generative_ai/versions), '
      'or file an issue at '
      'https://github.com/google-gemini/generative-ai-dart/issues.';
}

GenerativeAIException parseError(Object jsonObject) {
  return switch (jsonObject) {
    {
      'code': final int? code,
      'message': final String message,
      'details': [{'reason': 'API_KEY_INVALID'}, ...],
    } =>
      InvalidApiKey(message, code: code),
    {'message': UnsupportedUserLocation._message, 'code': final int? code} =>
      UnsupportedUserLocation(code: code),
    {
      'code': final int? code,
      'message': final String message,
      'details': final dynamic details,
    }
        when message.toLowerCase().contains('quota') =>
      QuotaExceeded(message, details, code: code),
    {'message': final String message, 'code': final int? code} =>
      ServerException(message, code: code),
    _ => throw unhandledFormat('server error', jsonObject)
  };
}

Exception unhandledFormat(String name, Object? jsonObject) =>
    GenerativeAISdkException('Unhandled format for $name: $jsonObject');
