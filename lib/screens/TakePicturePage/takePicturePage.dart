import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/shared/cameraProvider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final _cameraControllerInitializationFutureProvider =
    FutureProvider.autoDispose(
  (ref) async {
    final cameras = await ref.watch(camerasFutureProvider.future);
    final controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );

    await controller.initialize();

    ref.maintainState = true;
    return controller;
  },
);

final _recognisedTextStateProvider =
    StateProvider.autoDispose<RecognisedText?>((ref) {
  return null;
});

final _imageLabelsStateProvider =
    StateProvider.autoDispose<List<ImageLabel>?>((ref) {
  return null;
});

enum TtsState { playing, stopped, paused, continued }

class TakePicturePage extends ConsumerWidget {
  TakePicturePage({Key? key}) : super(key: key);

  final textDetector = GoogleMlKit.vision.textDetector();
  final imageLabeler = GoogleMlKit.vision.imageLabeler();

  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => TakePicturePage(),
    );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return watch(_cameraControllerInitializationFutureProvider).when(
      data: (controller) {
        return Scaffold(
          body: CameraPreview(controller),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final image = await controller.takePicture();
              try {
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

                context.read(_recognisedTextStateProvider).state =
                    recognisedText;
                context.read(_imageLabelsStateProvider).state = imageLabels;

                print('log: recognising text and labelling image...');

                for (var block in recognisedText.blocks) {
                  print(block.text);
                }

                for (var imageLabel in imageLabels) {
                  print(imageLabel.label);
                }
              } catch (e) {
                print('log: there was an error');
                print(e.toString());
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Image.file(File(image.path));
                  },
                ),
              );
            },
            child: Icon(Icons.camera_alt),
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) {
        return Center(
          child: Text(
            'Something went wrong: $error',
          ),
        );
      },
    );
  }
}
