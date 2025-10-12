import 'package:flutter/material.dart';
import '/widgets/animated_container.dart';
import '/widgets/animated_cross_fade.dart';
import '/widgets/animated_opacity.dart';
import '/widgets/animated_balloon.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Animation Examples")),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const <Widget>[
                AnimatedContainerWidget(),
                Divider(),
                AnimatedCrossFadeWidget(),
                Divider(),
                AnimatedOpacityWidget(),
                Divider(),
                AnimatedBalloonWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
