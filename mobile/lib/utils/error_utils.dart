import 'dart:async';
import 'dart:io';

String formatUserFriendlyError(Object error) {
  if (error is SocketException || error is TimeoutException) {
    return 'Unable to connect. Please try again.';
  }

  final rawMsg = error.toString().replaceAll('Exception: ', '').trim();

  if (rawMsg.contains('FormatException') ||
      rawMsg.contains('FormatUnexpected character') ||
      rawMsg.contains('SyntaxError')) {
    return 'Server error occurred. Please try again in a few moments.';
  }

  if (rawMsg.contains('SocketException') ||
      rawMsg.contains('ClientException') ||
      rawMsg.contains('Connection refused') ||
      rawMsg.contains('Failed host lookup')) {
    return 'Unable to connect to the server. Please try again.';
  }

  if (rawMsg.contains('500') || rawMsg.contains('Internal Server Error')) {
    return 'Server error. Please try again later.';
  }

  if (rawMsg.contains('502') ||
      rawMsg.contains('503') ||
      rawMsg.contains('504')) {
    return 'Service is temporarily unavailable. Please try again shortly.';
  }

  if (rawMsg.isEmpty) {
    return 'An unexpected error occurred. Please try again.';
  }

  return rawMsg;
}
