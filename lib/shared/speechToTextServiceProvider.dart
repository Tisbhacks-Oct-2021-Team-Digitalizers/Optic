import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

final speechToTextServiceProvider = Provider((ref) {
  final speechToTextService = SpeechToText();
  return speechToTextService;
});
