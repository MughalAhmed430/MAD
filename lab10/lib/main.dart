import 'dart:async';
import 'package:flutter/material.dart';
import 'effects.dart';

void main() {
  runApp(const ScrollingListsApp());
}

class ScrollingListsApp extends StatelessWidget {
  const ScrollingListsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrolling Lists and Effects',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

/// Home screen shows examples: ListView, Horizontal List, Slivers, AnimatedList and PageView.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<_ProcessItem> items =
  List.generate(12, (i) => _ProcessItem('P${i + 1}', duration: (i % 5) + 1));
  final GlobalKey<AnimatedListState> _animatedListKey = GlobalKey();
  late AnimationController _shimmerController;

  // PageView controller for parallax effect
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _shimmerController =
    AnimationController.unbounded(vsync: this)..repeat(min: 0.0, max: 1.0, period: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _insertItem() {
    final newItem = _ProcessItem('P${items.length + 1}', duration: (items.length % 5) + 1);
    items.insert(0, newItem);
    _animatedListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 450));
  }

  void _removeItem() {
    if (items.isEmpty) return;
    final removed = items.removeAt(0);
    _animatedListKey.currentState?.removeItem(
      0,
          (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: _buildProcessTile(removed, animation: animation),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildProcessTile(_ProcessItem p, {Animation<double>? animation}) {
    final child = ListTile(
      leading: CircleAvatar(child: Text(p.id.replaceAll('P', ''))),
      title: Text('Process ${p.id}'),
      subtitle: Text('Burst time: ${p.duration} units'),
      trailing: Icon(Icons.chevron_right),
    );

    if (animation != null) {
      return FadeScaleTransition(animation: animation, child: child);
    }
    return child;
  }

  Widget _buildVerticalList() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: SizedBox(
        height: 320,
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 8),
          itemBuilder: (context, index) {
            final p = items[index];
            return ListTile(
              leading: CircleAvatar(child: Text(p.id.replaceAll('P', ''))),
              title: Text('Process ${p.id}'),
              subtitle: Text('Arrival: ${p.arrival}  Burst: ${p.duration}'),
              trailing: Text('Prio ${p.priority}'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalList() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final p = items[index];
            return Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(color: Colors.indigo.shade100.withOpacity(0.6)),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Process ${p.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return SimpleGradientOverlay(progress: (_shimmerController.value % 1.0), child: Container());
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Burst: ${p.duration}'),
                  Text('Priority: ${p.priority}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverList() {
    return SizedBox(
      height: 280,
      child: Card(
        margin: const EdgeInsets.all(12),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 60,
              flexibleSpace: const FlexibleSpaceBar(title: Text('Sliver Process List')),
              backgroundColor: Colors.indigo,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final p = items[index % items.length];
                  return ListTile(
                    leading: CircleAvatar(child: Text(p.id.replaceAll('P', ''))),
                    title: Text('Process ${p.id}'),
                    subtitle: Text('Burst: ${p.duration}  Priority: ${p.priority}'),
                  );
                },
                childCount: items.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedList() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        height: 260,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  ElevatedButton.icon(onPressed: _insertItem, icon: const Icon(Icons.add), label: const Text('Insert')),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(onPressed: _removeItem, icon: const Icon(Icons.remove), label: const Text('Remove')),
                ],
              ),
            ),
            Expanded(
              child: AnimatedList(
                key: _animatedListKey,
                initialItemCount: items.length,
                itemBuilder: (context, index, animation) {
                  final p = items[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: _buildProcessTile(p, animation: animation),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: SizedBox(
        height: 220,
        child: PageView.builder(
          controller: _pageController,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _ParallaxPage(
              controller: _pageController,
              index: index,
              child: _pageCard(items[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _pageCard(_ProcessItem p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.indigo.shade50,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(radius: 30, child: Text(p.id.replaceAll('P', ''))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Process ${p.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Burst time: ${p.duration}'),
                    Text('Arrival time: ${p.arrival}'),
                  ],
                ),
              ),
              Text('Prio ${p.priority}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: const Text('Simulation Summary'),
        subtitle: const Text('Use lists and page views above to inspect process ordering and effects.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = <Widget>[
      const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Scrolling lists and effects demo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      _buildVerticalList(),
      _buildHorizontalList(),
      _buildSliverList(),
      _buildAnimatedList(),
      _buildPageView(),
      _buildResultsSummary(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Scrolling Lists & Effects')),
      body: ListView(
        children: top,
      ),
    );
  }
}

class _ParallaxPage extends StatefulWidget {
  final Widget child;
  final PageController controller;
  final int index;

  const _ParallaxPage({
    Key? key,
    required this.child,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  State<_ParallaxPage> createState() => _ParallaxPageState();
}

class _ParallaxPageState extends State<_ParallaxPage> {
  double _page = 0.0;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (!mounted) return;
      final p = widget.controller.hasClients ? widget.controller.page ?? widget.controller.initialPage.toDouble() : 0.0;
      setState(() => _page = p);
    };
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollPercent = (_page - widget.index);
    return ParallaxContainer(
      scrollPercent: scrollPercent,
      depth: 40,
      child: widget.child,
    );
  }
}

class _ProcessItem {
  final String id;
  final int duration;
  final int arrival;
  final int priority;

  _ProcessItem(this.id, {required this.duration, this.arrival = 0, this.priority = 1});
}
