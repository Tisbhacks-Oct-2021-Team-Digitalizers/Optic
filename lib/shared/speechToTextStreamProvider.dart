import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:optic/main.dart';
import 'package:optic/screens/TakePicturePage/takePicturePage.dart';
import 'package:optic/shared/cameraControllerFutureProvider.dart';
import 'package:optic/shared/speechToTextServiceProvider.dart';
import 'package:optic/shared/textToSpeechServiceProvider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:wikidart/wikidart.dart';

final speechToTextStreamProvider =
    StreamProvider.autoDispose<SpeechRecognitionResult?>((ref) async* {
  final speechToTextService = ref.watch(speechToTextServiceProvider);
  final tts = ref.watch(textToSpeechServiceProvider);
  final cameraController =
      await ref.watch(cameraControllerInitializationFutureProvider.future);

  final textDetector = GoogleMlKit.vision.textDetector();
  final imageLabeler = GoogleMlKit.vision.imageLabeler();

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
                    await tts.speak(info.extract!);
                  }
                }
              }
            } else if (result.recognizedWords.substring(0, 14) ==
                'take a picture') {
              appNavigatorKey.currentState?.push(TakePicturePage.route());

              final image = await cameraController.takePicture();

              final recognisedText = await textDetector.processImage(
                InputImage.fromFilePath(
                  image.path,
                ),
              );

              final imageLabels = await imageLabeler.processImage(
                InputImage.fromFilePath(
                  image.path,
                ),
              );

              await tts.speak('The image consists of');
              await Future.delayed(
                Duration(
                  seconds: 2,
                ),
              );

              for (var i = 0; i < imageLabels.length; i++) {
                if (i <= 2) {
                  print(imageLabels[i].label);
                  await tts.speak(imageLabels[i].label);
                }
              }

              await tts.speak('Reading text in image');

              if (recognisedText.text.trim().isEmpty) {
                await tts.speak('No text found in picture');
              }
              await tts.speak(recognisedText.text.toLowerCase());
              appNavigatorKey.currentState?.pop();
            } else if (result.recognizedWords.trim().toLowerCase() == 'stop') {
              print('log: will stop tts');
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
