import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/shared/speechToTextServiceProvider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

final speechToTextStreamProvider =
    StreamProvider.autoDispose<SpeechRecognitionResult?>((ref) async* {
  final speechToTextService =
      await ref.watch(speechToTextServiceProvider.future);

  final streamController = StreamController<SpeechRecognitionResult?>();
  streamController.add(null);

  if (!speechToTextService.isListening) {
    speechToTextService.listen(
      onResult: (result) {
        print('log: got speech result');
        streamController.add(result);
      },
    );
  }

  ref.onDispose(() {
    speechToTextService.stop();
    streamController.close();
  });

  yield* streamController.stream;
});
