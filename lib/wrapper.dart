import 'package:flutter/material.dart';
import 'package:optic/screens/HomePage/homepage.dart';
import 'package:optic/screens/LoginPage/loginPage.dart';
import 'package:optic/shared/authStateProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Wrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return watch(authStateProvider).when(
      data: (user) {
        if (user == null) {
          return LoginPage();
        } else {
          return HomePage();
        }
      },
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Text(
        '$error',
      ),
    );
  }
}
