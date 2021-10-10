import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/shared/cameraProvider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:optic/shared/textToSpeechServiceProvider.dart';

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

// final _imageLabelsStateProvider =
//     StateProvider.autoDispose<List<ImageLabel>?>((ref) {
//   return null;
// });

class TakePicturePage extends ConsumerWidget {
  TakePicturePage({Key? key}) : super(key: key);

  final textDetector = GoogleMlKit.vision.textDetector();
  final imageLabeler = GoogleMlKit.vision.imageLabeler();

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
              final tts = context.read(textToSpeechServiceProvider);

              await tts.speak('Reading');

              try {
                final recognisedText = await textDetector.processImage(
                  InputImage.fromFilePath(
                    image.path,
                  ),
                );

                // final imageLabels = await imageLabeler.processImage(
                //   InputImage.fromFilePath(
                //     image.path,
                //   ),
                // );

                context.read(_recognisedTextStateProvider).state =
                    recognisedText;
                // context.read(_imageLabelsStateProvider).state = imageLabels;

                print('log: recognising text and labelling image...');
                await Future.delayed(Duration(seconds: 2));
                print(recognisedText.text);
                await tts.speak(recognisedText.text.toLowerCase());

                // for (var block in recognisedText.blocks) {
                //   print(block.text);
                //   await tts.speak(block.text.toLowerCase());
                // }

                // for (var imageLabel in imageLabels) {
                //   print(imageLabel.label);
                // }

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
