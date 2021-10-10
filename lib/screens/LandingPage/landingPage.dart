import 'package:flutter/material.dart';
import 'package:optic/screens/TakePicturePage/takePicturePage.dart';
import 'package:optic/services/auth.dart';
import 'package:optic/shared/speechToTextStreamProvider.dart';
import 'package:optic/shared/userDataStream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return watch(userDataStreamProvider).when<Widget>(
      data: (userData) {
        if (userData == null) {
          return Container();
        }
        return watch(speechToTextStreamProvider).when(
          data: (result) {
            print(result?.recognizedWords);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      userData.photoUrl!,
                    ),
                  ),
                  Text(
                    userData.displayName ?? '',
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final authService = context.read(authServiceProvider);
                      await authService.signOut();
                    },
                    child: Text(
                      'Log out',
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(context).push(
                        TakePicturePage.route(),
                      );
                    },
                    icon: Icon(Icons.camera),
                    label: Text(
                      'Take Picture',
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      context.refresh(speechToTextStreamProvider);
                    },
                    icon: Icon(Icons.mic),
                    label: Text(
                      'Record',
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () {
            print('log: loading in stream');
            return Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text(
                'Something went wrong: $error',
              ),
            );
          },
        );
      },
      loading: () {
        print('log: loading user data');
        return Center(
          child: CircularProgressIndicator(),
        );
      },
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
