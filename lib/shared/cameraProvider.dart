import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final camerasFutureProvider = FutureProvider.autoDispose((ref) async {
  final cameras = await availableCameras();
  ref.maintainState = true;
  return cameras;
});
