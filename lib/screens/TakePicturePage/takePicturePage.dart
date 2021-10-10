import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/shared/cameraControllerFutureProvider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

// final _imageLabelsStateProvider =
//     StateProvider.autoDispose<List<ImageLabel>?>((ref) {
//   return null;
// });

class TakePicturePage extends ConsumerWidget {
  TakePicturePage({Key? key}) : super(key: key);

  final imageLabeler = GoogleMlKit.vision.imageLabeler();

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => TakePicturePage(),
    );
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return watch(cameraControllerInitializationFutureProvider).when(
      data: (controller) {
        return Scaffold(
          body: CameraPreview(controller),
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
