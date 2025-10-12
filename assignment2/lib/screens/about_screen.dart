import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final List<Map<String, String>> attractions = [
    {
      'image': 'assets/images/eiffel.jpg',
      'title': 'Eiffel Tower',
      'desc':
      'Located in Paris, France, the Eiffel Tower is an architectural marvel built in 1889. Standing over 300 meters tall, it attracts millions of visitors each year. The tower offers breathtaking panoramic views of the city and sparkles with lights every night.'
    },
    {
      'image': 'assets/images/taj.jpg',
      'title': 'Taj Mahal',
      'desc':
      'The Taj Mahal, located in Agra, India, was built by Mughal Emperor Shah Jahan in memory of his wife Mumtaz Mahal. Made of white marble, it is admired worldwide as a symbol of love and architectural perfection. It’s one of the Seven Wonders of the World.'
    },
    {
      'image': 'assets/images/badshahi.jpg',
      'title': 'Badshahi Mosque',
      'desc':
      'Built in 1673 by Emperor Aurangzeb in Lahore, Pakistan, the Badshahi Mosque is a masterpiece of Mughal architecture. Its vast courtyard and red sandstone walls reflect a glorious era. The mosque remains one of the largest in the world.'
    },
    {
      'image': 'assets/images/table_mountain.jpg',
      'title': 'Table Mountain',
      'desc':
      'Table Mountain overlooks Cape Town, South Africa, and is known for its flat summit. Visitors can hike or take the cableway to experience stunning city and ocean views. It’s a symbol of natural beauty and adventure for travelers.'
    },
    {
      'image': 'assets/images/shangrila.jpg',
      'title': 'Shangrila Resort',
      'desc':
      'Shangrila Resort, located near Skardu, Pakistan, is surrounded by serene mountains and the beautiful Lower Kachura Lake. Its calm environment and Swiss-style cottages make it a true paradise, often called “Heaven on Earth.”'
    },
    {
      'image': 'assets/images/karakoram.jpg',
      'title': 'Karakoram Range',
      'desc':
      'The Karakoram Mountains span across Pakistan, India, and China, hosting some of the highest peaks, including K2. Known for glaciers and rugged beauty, it’s a dream destination for climbers and adventure seekers worldwide.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900
        ? 4
        : width > 700
        ? 3
        : 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Famous Attractions'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            itemCount: attractions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // Makes room for image + 4-line text
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              final a = attractions[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          a['image']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a['title']!,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                a['desc']!,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
