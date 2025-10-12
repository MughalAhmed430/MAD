import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../screens/detail_screen.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({required this.destination, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        leading: Hero(
          tag: destination.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              destination.imageAsset,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(destination.name, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(destination.shortDesc),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(destination: destination)),
          );
        },
      ),
    );
  }
}
