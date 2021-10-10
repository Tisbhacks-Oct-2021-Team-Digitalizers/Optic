import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/shared/speechToTextServiceProvider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

final speechToTextStreamProvider =
    StreamProvider.autoDispose<SpeechRecognitionResult?>((ref) async* {
  final speechToTextService = ref.watch(speechToTextServiceProvider);

  final streamController = StreamController<SpeechRecognitionResult?>();
  streamController.add(null);

  if (!speechToTextService.isAvailable) {
    print('log: initializing speech to text service');
    await speechToTextService.initialize(
      onStatus: (status) {
        print('log: listening status is: $status');
      },
      onError: (val) => print('onError: $val'),
    );
  }

  if (!speechToTextService.isListening) {
    await speechToTextService.listen(
      onDevice: true,
      onResult: (result) {
        print('log: got speech result');
        print('the result is: ${result.recognizedWords}');
        streamController.add(result);
      },
    );
  } else {
    print('log: stopping listening...');
    await speechToTextService.stop();
  }

  ref.onDispose(() async {
    if (speechToTextService.isListening) {
      await speechToTextService.stop();
    }
    streamController.close();
  });

  yield* streamController.stream;
});
