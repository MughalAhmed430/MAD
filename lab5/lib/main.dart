import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Tree Example'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                // First Row
                Row(
                  children: <Widget>[
                    Container(color: Colors.yellow, height: 40.0, width: 40.0),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Container(color: Colors.amber, height: 40.0),
                    ),
                    const SizedBox(width: 16.0),
                    Container(color: Colors.brown, height: 40.0, width: 40.0),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Second Row -> Column inside
                Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(color: Colors.yellow, height: 60.0, width: 60.0),
                        const SizedBox(height: 16.0),
                        Container(color: Colors.amber, height: 40.0, width: 40.0),
                        const SizedBox(height: 16.0),
                        Container(color: Colors.brown, height: 20.0, width: 20.0),
                      ],
                    ),
                  ],
                ),
                const Divider(),

                // Circle Avatar with Stack
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.lightGreen,
                      radius: 100.0,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 100.0,
                            width: 100.0,
                            color: Colors.yellow,
                          ),
                          Container(
                            height: 60.0,
                            width: 60.0,
                            color: Colors.amber,
                          ),
                          Container(
                            height: 40.0,
                            width: 40.0,
                            color: Colors.brown,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),

                // End text
                const Text(
                  'End of the Line',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
