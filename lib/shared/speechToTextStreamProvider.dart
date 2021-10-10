import 'dart:async';

// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/main.dart';
import 'package:optic/screens/TakePicturePage/takePicturePage.dart';
import 'package:optic/shared/speechToTextServiceProvider.dart';
import 'package:optic/shared/textToSpeechServiceProvider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:wikidart/wikidart.dart';

final speechToTextStreamProvider =
    StreamProvider.autoDispose<SpeechRecognitionResult?>((ref) async* {
  final speechToTextService = ref.watch(speechToTextServiceProvider);

  final streamController = StreamController<SpeechRecognitionResult?>();
  streamController.add(null);

  final tts = ref.watch(textToSpeechServiceProvider);

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
      onResult: (result) async {
        print('log: got speech result');
        print('the result is: ${result.recognizedWords}');
        streamController.add(result);
        if (result.finalResult) {
          if (result.recognizedWords != '') {
            if (result.recognizedWords.substring(0, 10) == 'search for') {
              var res = await Wikidart.searchQuery(
                  result.recognizedWords.substring(11));
              var pageid = res?.results?.first.pageId;

              if (pageid != null) {
                var info = await Wikidart.summary(pageid);
                if (info != null) {
                  print(info.title);
                  print(info.description);
                  print(info.extract);
                  if (info.extract != null) {
                    tts.speak(info.extract!);
                  }
                }
              }
            } else if (result.recognizedWords == 'take a picture') {
              appNavigatorKey.currentState?.push(TakePicturePage.route());
            } else if (result.recognizedWords == 'stop') {
              tts.stop();
            }
          }
        }
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
