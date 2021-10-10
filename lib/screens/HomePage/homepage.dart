import 'package:flutter/material.dart';
import 'package:optic/screens/LandingPage/landingPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/shared/userDataStream.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Optic'),
        centerTitle: true,
        actions: [
          watch(userDataStreamProvider).when(
            data: (userData) {
              if (userData == null) {
                return Container();
              }
              return CircleAvatar(
                backgroundImage: NetworkImage(
                  userData.photoUrl!,
                ),
              );
            },
            loading: () => CircleAvatar(),
            error: (error, stackTrace) => CircleAvatar(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
      body: LandingPage(),
    );
  }
}
