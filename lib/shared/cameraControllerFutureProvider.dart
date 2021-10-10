import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/shared/cameraProvider.dart';

final cameraControllerInitializationFutureProvider = FutureProvider.autoDispose(
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
