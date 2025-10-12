import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../widgets/destination_card.dart';

class ListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: sampleDestinations.length,
      itemBuilder: (ctx, i) => DestinationCard(destination: sampleDestinations[i]),
    );
  }
}
