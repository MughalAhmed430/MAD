import 'package:flutter/material.dart';

void main() {
  runApp(const FlashcardsApp());
}

class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FlashcardScreen(),
      theme: ThemeData.dark(),
    );
  }
}

class Flashcard {
  String question;
  String answer;
  bool isLearned;
  bool isExpanded;
  Flashcard(this.question, this.answer,
      {this.isLearned = false, this.isExpanded = false});
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});
  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  late List<Flashcard> flashcards;

  @override
  void initState() {
    super.initState();
    flashcards = _generateCards();
  }

  List<Flashcard> _generateCards() {
    final data = [
      ['What is the capital of France?', 'Paris'],
      ['Who wrote "Hamlet"?', 'William Shakespeare'],
      ['Which planet is known as the Red Planet?', 'Mars'],
      ['What is the largest ocean on Earth?', 'Pacific Ocean'],
      ['Who painted the Mona Lisa?', 'Leonardo da Vinci'],
      ['What is the tallest mountain in the world?', 'Mount Everest'],
      ['Who discovered gravity?', 'Isaac Newton'],
      ['Which gas do plants absorb from the atmosphere?', 'Carbon dioxide'],
      ['In which year did World War II end?', '1945'],
      ['What is the chemical symbol for water?', 'H₂O'],
      ['Who was the first man to step on the Moon?', 'Neil Armstrong'],
      ['What is the largest continent?', 'Asia'],
      ['Who is known as the Father of Computers?', 'Charles Babbage'],
      ['Which planet is closest to the Sun?', 'Mercury'],
      ['What is the fastest land animal?', 'Cheetah'],
      ['Which country is known as the Land of the Rising Sun?', 'Japan'],
      ['What is the hardest natural substance?', 'Diamond'],
      ['Who invented the telephone?', 'Alexander Graham Bell'],
      ['Which element has the symbol "O"?', 'Oxygen'],
      ['What is the smallest prime number?', '2'],
      ['Which organ pumps blood through the human body?', 'Heart'],
      ['Who painted "The Starry Night"?', 'Vincent van Gogh'],
      ['What is the national flower of Pakistan?', 'Jasmine'],
      ['Who discovered penicillin?', 'Alexander Fleming'],
      ['Which planet has rings around it?', 'Saturn'],
      ['In which country are the Pyramids of Giza?', 'Egypt'],
      ['What is the largest mammal?', 'Blue Whale'],
      ['Who was the first President of the United States?', 'George Washington'],
      ['What is the boiling point of water?', '100°C'],
      ['Which language has the most native speakers?', 'Mandarin Chinese'],
      ['Who wrote "Pride and Prejudice"?', 'Jane Austen'],
      ['Which metal is liquid at room temperature?', 'Mercury'],
      ['Who developed the theory of relativity?', 'Albert Einstein'],
      ['What is the national animal of Australia?', 'Kangaroo'],
      ['How many continents are there on Earth?', '7'],
      ['What is the chemical symbol for gold?', 'Au'],
      ['Who invented the light bulb?', 'Thomas Edison'],
      ['Which city is known as the City of Love?', 'Paris'],
      ['What is the square root of 81?', '9'],
      ['Who was known as the Iron Lady?', 'Margaret Thatcher'],
      ['What is the largest desert in the world?', 'Sahara Desert'],
      ['Which blood type is known as the universal donor?', 'O negative'],
      ['Who composed "Fur Elise"?', 'Ludwig van Beethoven'],
      ['What is the capital city of Canada?', 'Ottawa'],
      ['Which is the longest river in the world?', 'Nile River'],
      ['Who discovered America?', 'Christopher Columbus'],
      ['What is the main gas found in the air we breathe?', 'Nitrogen'],
      ['Which country invented paper?', 'China'],
      ['What is the freezing point of water?', '0°C'],
      ['Which instrument measures temperature?', 'Thermometer'],
    ];
    return data.map((q) => Flashcard(q[0], q[1])).toList();
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      flashcards.shuffle();
    });
  }

  void _addNewFlashcard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _questionController.clear();
              _answerController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_questionController.text.isNotEmpty &&
                  _answerController.text.isNotEmpty) {
                final newCard = Flashcard(
                  _questionController.text,
                  _answerController.text,
                );

                setState(() {
                  flashcards.insert(0, newCard);
                });

                _questionController.clear();
                _answerController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _markAsLearned(int index) {
    setState(() {
      flashcards[index].isLearned = !flashcards[index].isLearned;
    });
  }

  void _deleteCard(int index) {
    final deletedCard = flashcards[index];
    setState(() {
      flashcards.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Card deleted!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              flashcards.insert(index, deletedCard);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  int get learnedCount => flashcards.where((f) => f.isLearned).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFlashcard,
        backgroundColor: const Color(0xFF2C5364),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              floating: false,
              pinned: true,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Flashcards\n$learnedCount of ${flashcards.length} learned',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                centerTitle: true,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final card = flashcards[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Dismissible(
                      key: ValueKey('${card.question}-$index'),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 30),
                            SizedBox(width: 10),
                            Text('Mark Learned',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFEB3349), Color(0xFFF45C43)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Delete',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                            SizedBox(width: 10),
                            Icon(Icons.delete, color: Colors.white, size: 30),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Swipe left to right - Mark as learned
                          setState(() {
                            card.isLearned = !card.isLearned;
                          });
                          return false; // Don't dismiss, just mark as learned
                        } else {
                          // Swipe right to left - Delete card
                          _deleteCard(index);
                          return true; // Dismiss the card
                        }
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            card.isExpanded = !card.isExpanded;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: card.isLearned
                                  ? [const Color(0xFF00b09b), const Color(0xFF96c93d)]
                                  : [const Color(0xFF232526), const Color(0xFF414345)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: card.isLearned
                                ? Border.all(color: Colors.green, width: 2)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      card.question,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        decoration: card.isLearned
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  if (card.isLearned)
                                    const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  if (card.isExpanded)
                                    const Icon(Icons.expand_less, color: Colors.white70)
                                  else
                                    const Icon(Icons.expand_more, color: Colors.white70),
                                ],
                              ),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 250),
                                firstChild: const SizedBox.shrink(),
                                secondChild: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(color: Colors.white54),
                                      Text(
                                        card.answer,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                                crossFadeState: card.isExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: flashcards.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}