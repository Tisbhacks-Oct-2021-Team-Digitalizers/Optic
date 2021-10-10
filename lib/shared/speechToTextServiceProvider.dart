import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

final speechToTextServiceProvider = FutureProvider((ref) async {
  final speechToTextService = SpeechToText();
  if (!speechToTextService.isAvailable) {
    print('log: initializing speech to text service');
    await speechToTextService.initialize(
      onError: (error) {
        print(error.errorMsg);
      },
    );
  }
  return speechToTextService;
});
