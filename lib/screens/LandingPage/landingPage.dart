import 'package:flutter/material.dart';
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                SizedBox(
                  height: 400,
                  width: 300,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff71CDC2),
                    ),
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
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: watch(speechToTextStreamProvider).when(
                    data: (result) {
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              result?.recognizedWords.toLowerCase() ?? '',
                              style: TextStyle(
                                fontSize: 22.0,
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
                ),
              ],
            ),
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
