import 'package:flutter/material.dart';
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    onPressed: () async {
                      final authService = context.read(authServiceProvider);
                      await authService.signOut();
                    },
                    child: Text(
                      'Log out',
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 300,
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    context.refresh(speechToTextStreamProvider);
                  },
                  icon: Icon(
                    Icons.mic,
                    size: 30.0,
                  ),
                  label: Text(
                    'Record',
                    style: TextStyle(
                      fontSize: 30.0,
                    ),
                  ),
                ),
              ),
              watch(speechToTextStreamProvider).when(
                data: (result) {
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          result?.recognizedWords ?? 'nothing said',
                          style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
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
              ),
            ],
          ),
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
