import 'package:flutter/material.dart';
import 'package:optic/screens/LandingPage/landingPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optic/services/auth.dart';
import 'package:optic/shared/userDataStream.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      backgroundColor: Color(0xffC5E5E9),
      appBar: AppBar(
        backgroundColor: Color(0xff00A6A0),
        leading: watch(userDataStreamProvider).when(
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
        title: Text('Optic'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              final authService = context.read(authServiceProvider);
              authService.signOut();
            },
            icon: Icon(
              Icons.logout,
              size: 20,
            ),
          ),
        ],
      ),
      body: LandingPage(),
    );
  }
}
