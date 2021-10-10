import 'package:flutter/material.dart';
import 'package:optic/services/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final authService = watch(authServiceProvider);
    return Scaffold(
      backgroundColor: Color(0xff71CDC2),
      body: authService.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff00A6A0),
                      ),
                      onPressed: () async {
                        final authService = context.read(authServiceProvider);
                        await authService.signInWithGoogle();
                      },
                      icon: Icon(
                        Icons.person,
                      ),
                      label: Text(
                        'Sign In',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
