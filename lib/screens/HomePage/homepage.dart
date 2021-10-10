import 'package:flutter/material.dart';
import 'package:optic/screens/LandingPage/landingpage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  List<Widget> get bodyWidgets {
    return [
      LandingPage(),
    ];
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      body: bodyWidgets[0],
    );
  }
}
