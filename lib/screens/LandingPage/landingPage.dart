import 'package:flutter/material.dart';
import 'package:optic/services/auth.dart';
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
        print('HEY HEY HEY user photo url is: ${userData.photoUrl}');
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
            ],
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) {
        print(stackTrace);
        return Center(
          child: Text(
            'Something went wrong: $error',
          ),
        );
      },
    );
  }
}
