import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: isWide ? 320 : 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset('assets/images/cover.jpg', fit: BoxFit.cover),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Welcome to TravelGuide — explore real places, tips, and photos!', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 20, color: Colors.black),
              children: [
                TextSpan(text: 'Explore '),
                TextSpan(text: 'the World', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                TextSpan(text: ' with Us'),
              ],
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Search destination',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Searching for: $value')));
            },
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                  onPressed: () {
                    final val = _controller.text;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Searching for: $val')));
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.info_outline),
                  label: Text('Tips'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Travel Tips'),
                        content: Text('Pack light, check weather, and try local foods!'),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
